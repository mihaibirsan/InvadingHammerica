/*
 * RiskServerHandler.cpp
 *
 *  Created on: Feb 4, 2011
 *      Author: mihaibirsan
 */

#include <stdio.h>
#include "RiskClientSocket.h"
#include "RiskServerHandler.h"

RiskServerHandler::RiskServerHandler()
:SocketHandler()
{
}


RiskServerHandler::~RiskServerHandler()
{
	// Delete all rooms
	while (rooms.size())
	{
		delete rooms.back();
		rooms.pop_back();
	}
}


/**
 * Messages are JSON objects that simulate a callback. For example the command
 * `game.bid(5)` would be simualted as `{ "game_bid": { "goldAmmount": 5 } }`.
 */
void RiskServerHandler::HandleMessage(RiskClientSocket& client, const std::string& line)
{
	// translate the message into a JsonValue
	Json::Value message;
	if (!jsonReader.parse(line, message)) {
		std::string encoded = jsonWriter.write(jsonReader.getFormatedErrorMessages());
		client.Send("{ 'message': { 'error': " + encoded.substr(0, encoded.length()-1) + " } }\n");
		return;
	}
	if (!message.getMemberNames().size()) {
		client.Send("{ 'message': { 'error': \"No command sent.\" } }\n");
		return;
	}

	// Handle or delegate message
	std::string commandName = message.getMemberNames().front();
	Json::Value& params = message[commandName];

	printf("%s: %s", commandName.c_str(), jsonWriter.write(params).c_str());

	if (commandName == "hello")
	{
		// TODO: Handle authentication
		client.Hello();
		BroadcastLobbyStateData();
	}

	else if (commandName == "personal-set")
	{
		// Handle setting personal details
		if (message[commandName].isMember("newName")) {
			client.name = message[commandName]["newName"].asString();
		}
		if (message[commandName].isMember("newColor")) {
			client.color = message[commandName]["newColor"].asString();
		}

		if (client.HasRoom()) {
			client.GetRoom()->BroadcastStateData();
		}
		BroadcastLobbyStateData();
	}

	else if (commandName == "room-create")
	{
		// Create room, if not part of a room already
		if (!client.HasRoom()) {
			Room* newRoom = new Room();
			newRoom->AddClient(&client);

			rooms.push_back(newRoom);

			BroadcastLobbyStateData();
		}
	}

	else if (commandName == "room-join")
	{
		// Join room, if not part of a room already
		if (!client.HasRoom())
		{
			Room* newRoom = NULL;
			for (std::list<Room*>::iterator i = rooms.begin(); i != rooms.end(); ++i)
			{
				if ((*i)->id == params["id"].asInt())
				{
					newRoom = *i;
					break;
				}
			}

			if (newRoom != NULL)
			{
				newRoom->AddClient(&client);
				BroadcastLobbyStateData();
			}
		}
	}

	else if (commandName == "room-leave")
	{
		// Leave room, if part of one
		RemoveClientFromRoom(client);
	}

	else if (commandName.find("room-") == 0 || commandName.find("game-") == 0)
	{
		// Delegate the command to the room, if part of a room
		if (client.HasRoom()) {
			client.GetRoom()->HandleMessage(client, message);
			if (commandName.find("room-") == 0) BroadcastLobbyStateData();
		}
	}
}


void RiskServerHandler::RemoveClientFromRoom(RiskClientSocket& client)
{
	if (client.HasRoom())
	{
		Room* oldRoom = client.GetRoom();
		oldRoom->RemoveClient(&client);

		if (oldRoom->GetClientCount() == 0)
		{
			// Delete empty room
			rooms.remove(oldRoom);
			delete oldRoom;
		}

		BroadcastLobbyStateData();
	}
}


void RiskServerHandler::BroadcastLobbyStateData()
{
	Json::Value lobbyStateData;

	lobbyStateData["rooms"] = Json::Value(Json::arrayValue);
	for (std::list<Room*>::iterator i = rooms.begin(); i != rooms.end(); ++i)
	{
		if (!(*i)->IsAvailable()) continue;

		Json::Value room;
		room["id"] = (*i)->id;
		room["name"] = (*i)->name;
		room["playerNames"] = (*i)->GetPlayerNames();

		lobbyStateData["rooms"].append(room);
	}

	// For each client without a room, send lobbyStateData
	for (socket_m::iterator it = m_sockets.begin(); it != m_sockets.end(); it++)
	{
		Socket *p0 = (*it).second;
		RiskClientSocket *p = dynamic_cast<RiskClientSocket *>(p0);
		if (p)
		{
			if (!p->HasRoom()) p->SendCommand("lobby-announce", lobbyStateData);
		}
	}
}

