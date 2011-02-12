/*
 * Room.cpp
 *
 *  Created on: Feb 4, 2011
 *      Author: mihaibirsan
 */

#include <stdio.h>
#include "Room.h"

int RoomId = 0;

Room::Room()
:Thread(true)
,gameStarted(false)
{
	id = ++RoomId;
}


Room::~Room()
{
}


void Room::Run()
{
	std::list<RiskClientSocket*>::iterator i;

// Wait for 2-4 players to connect
	Sleep();

// Decide turn order
	// Send all players the 'game-bid' command
	for (i = clients.begin(); i != clients.end(); ++i)
	{
		(*i)->lastBid = -1;
		(*i)->GameBid();
	}

	// Wait until all players have responded to the bid
	while (true)
	{
		Sleep();
		for (i = clients.begin(); i != clients.end(); ++i)
			if ((*i)->lastBid == -1) break;
		if (i == clients.end()) break;
	}

	// Take everyone's gold
	for (i = clients.begin(); i != clients.end(); ++i)
	{
		if ((*i)->lastBid > (*i)->gold) (*i)->lastBid = (*i)->gold;
		(*i)->gold -= (*i)->lastBid;
	}
	BroadcastStateData();

	// Sort players by bid
	clients.sort();

// Place initial armies
	int initialArmies = 50, maxArmies = 4;
	if (clients.size() > 2) initialArmies = 35;
	while (initialArmies > 0)
	{
		if (maxArmies > initialArmies) maxArmies = initialArmies;
		for (i = clients.begin(); i != clients.end(); ++i)
		{
			// Send player the 'game-placeArmies { count: }'
			(*i)->GamePlaceArmies(maxArmies);
			Sleep(); // TODO: Make sure we wake up from the right event
		}
		initialArmies -= maxArmies;
		maxArmies = 3;
	}

	Sleep(); // XXX: Deadlock, because further code not implemented

// Play 5 rounds
	for (int roundNumber = 0; roundNumber < 5; roundNumber++)
	{
	// Decide turn order
		// Send all players the 'game-bid' command
		for (i = clients.begin(); i != clients.end(); ++i)
		{
			(*i)->lastBid = -1;
			(*i)->GameBid();
		}

		// Wait until all players have responded to the bid
		while (true)
		{
			Sleep();
			for (i = clients.begin(); i != clients.end(); ++i)
				if ((*i)->lastBid == -1) break;
			if (i == clients.end()) break;
		}

		// Sort players by bid
		clients.sort();


		for (i = clients.begin(); i != clients.end(); ++i)
		{
			// TODO
			// ~Gain armies
			// player.placeArmies
			// player.carryBattles
			// player.fortify
			// ~Earn gold
		}
	}

// ~Count points and declare winners
}


void Room::Sleep()
{
	m_sem.Wait();
}

void Room::Wakeup()
{
	m_sem.Post();
}


void Room::HandleMessage(RiskClientSocket& client, Json::Value& message)
{
	std::string commandName = message.getMemberNames().front();
	Json::Value& params = message[commandName];

	if (commandName == "room-set")
	{
		if (params.isMember("newName")) {
			name = params["newName"].asString();
		}
		BroadcastStateData();
	}

	else if (commandName == "room-ready")
	{
		if (params.isMember("status")) {
			client.ready = params["status"].asBool();
		}
		BroadcastStateData();
	}

	else if (commandName == "room-begin")
	{
		// XXX: Check if the caller is the owner
		// TODO: Check if all players are ready
		gameStarted = true;
		BroadcastStateData();
		Wakeup();
	}

	else if (commandName == "game-bid")
	{
		client.lastBid = params["goldAmmount"].asInt();
		Wakeup();
	}

	else if (commandName == "game-placeArmies")
	{
		// TODO: Update territories
		/*
		std::list<std::string> memberNames = params["territories"].getMemberNames();
		for (std::vector<std::string> mn = memberNames.begin(); mn != memberNames.end(); ++mn)
		{
			if (territories.isMember(*mn)) {
				territories[*mn] = territories[*mn].asInt() + params["territories"][*mn].asInt();
			} else {
				territories[*mn] = params["territories"][*mn];
			}
		}
		*/
		Wakeup();
	}

	else if (commandName == "game-battle")
	{
		// TODO
	}

	else if (commandName == "game-battleCancel")
	{
		// TODO
	}

	else if (commandName == "game-chooseDieCount")
	{
		// TODO
	}

	else if (commandName == "game-spendGhosts")
	{
		// TODO
	}

	else if (commandName == "game-chooseArmyMoveCount")
	{
		// TODO
	}

	else if (commandName == "game-fortify")
	{
		// TODO
	}
}


void Room::RemoveClient(RiskClientSocket *riskClientSocket)
{
	// If the client doesn't exists, ignore request
	std::list<RiskClientSocket*>::iterator i;
	for (i = clients.begin(); i != clients.end(); ++i)
		if (*i == riskClientSocket) break;
	if (i == clients.end()) return;

	clients.remove(riskClientSocket);
	riskClientSocket->SetRoom(NULL);

	BroadcastStateData();
}


void Room::AddClient(RiskClientSocket *riskClientSocket)
{
	// If full, ignore request
	if (clients.size() == 4) return;

	// If the client already exists, ignore request
	for (std::list<RiskClientSocket*>::iterator i = clients.begin(); i != clients.end(); ++i)
		if (*i == riskClientSocket) return;

	clients.push_back(riskClientSocket);
	riskClientSocket->SetRoom(this);

	BroadcastStateData();
}


bool Room::IsAvailable()
{
	return !gameStarted && clients.size() < 4;
}


int  Room::GetClientCount()
{
	return clients.size();
}


std::string Room::GetPlayerNames()
{
	std::string playerNames = "";
	for (std::list<RiskClientSocket*>::iterator i = clients.begin(); i != clients.end(); ++i)
	{
		playerNames += (*i)->name + ", ";
	}
	if (playerNames.length() > 2) return playerNames.substr(0, playerNames.length()-2);
	return playerNames;
}


void Room::BroadcastStateData()
{
	if (gameStarted) BroadcastGameStateData();
	else BroadcastRoomStateData();
}

void Room::BroadcastRoomStateData()
{
	Json::Value roomStateData; // XXX: Maybe this data could be stored on a class level instead of computing over and over again
	bool allReady = true;

	roomStateData["id"] = id;
	roomStateData["name"] = name;

	roomStateData["players"] = Json::Value(Json::arrayValue);
	for (std::list<RiskClientSocket*>::iterator i = clients.begin(); i != clients.end(); ++i)
	{
		allReady = allReady && (*i)->ready;

		Json::Value player;
		player["id"] = (*i)->id;
		player["name"] = (*i)->name;
		player["color"] = (*i)->color;
		player["ready"] = (*i)->ready;
		roomStateData["players"].append(player);
	}

	if (clients.size() < 2) allReady = false;
	roomStateData["allReady"] = allReady;

	// Broadcast stateData to all participants
	for (std::list<RiskClientSocket*>::iterator i = clients.begin(); i != clients.end(); ++i)
	{
		(*i)->SendCommand("room-announce", roomStateData);
	}
}

void Room::BroadcastGameStateData()
{
	Json::Value gameStateData; // XXX: Maybe this data could be stored on a class level instead of computing over and over again

	gameStateData["territories"] = territories;

	gameStateData["players"] = Json::Value(Json::arrayValue);
	for (std::list<RiskClientSocket*>::iterator i = clients.begin(); i != clients.end(); ++i)
	{
		Json::Value player;
		player["id"] = (*i)->id;
		player["name"] = (*i)->name;
		player["color"] = (*i)->color;
		player["gold"] = (*i)->gold;
		player["ghost"] = (*i)->ghosts;
		gameStateData["players"].append(player);
	}

	// Broadcast stateData to all participants
	for (std::list<RiskClientSocket*>::iterator i = clients.begin(); i != clients.end(); ++i)
	{
		(*i)->SendCommand("game-announce", gameStateData);
	}
}
