/*
 * RiskClientSocket.cpp
 *
 *  Created on: Feb 4, 2011
 *      Author: mihaibirsan
 */

#include "RiskClientSocket.h"
#include "RiskServerHandler.h"
#include "Room.h"

int RiskClientSocketId = 0;

RiskClientSocket::RiskClientSocket(ISocketHandler& h)
:TcpSocket(h)
,room(NULL)
{
	SetLineProtocol();

	id = ++RiskClientSocketId;
	gold = 100;
}


RiskClientSocket::~RiskClientSocket()
{
}


void RiskClientSocket::OnLine(const std::string & line)
{
	static_cast<RiskServerHandler&>(Handler()).HandleMessage(*this, line);
}


void RiskClientSocket::OnDisconnect()
{
	static_cast<RiskServerHandler&>(Handler()).RemoveClientFromRoom(*this);
}


bool RiskClientSocket::HasRoom()
{
	return room != NULL;
}


Room* RiskClientSocket::GetRoom()
{
	return room;
}

void RiskClientSocket::SetRoom(Room* newRoom)
{
	if (room == newRoom) return;
	if (room != NULL)
	{
		// Remove self from room
		room->RemoveClient(this);
	}
	room = newRoom;
	ready = false;
	if (room != NULL)
	{
		// Add self to room
		room->AddClient(this);
	}
}

int operator<(const RiskClientSocket& left, const RiskClientSocket& right)
{
	if (left.lastBid < right.lastBid) return 1;
	return 0;
}

void RiskClientSocket::SendCommand(const std::string& command, const Json::Value& params)
{
	Json::Value message;
	message[command] = params;
	Send(jsonWriter.write(message));
}


void RiskClientSocket::Hello()
{
	Json::Value params;
	params["id"] = id;
	SendCommand("hello", params);
}


void RiskClientSocket::GameBid()
{
	SendCommand("game-bid", Json::Value(Json::objectValue));
}

void RiskClientSocket::GamePlaceArmies(int count)
{
	Json::Value params;
	params["count"] = count;
	SendCommand("game-placeArmies", params);
}

void RiskClientSocket::Battle()
{
	SendCommand("game-battle", Json::Value(Json::objectValue));
}

void RiskClientSocket::ChooseDieCount(int maxCount)
{
	Json::Value params;
	params["maxCount"] = maxCount;
	SendCommand("game-chooseDieCount", params);
}

void RiskClientSocket::SpendGhosts()
{
	SendCommand("game-spendGhosts", Json::Value(Json::objectValue));
}

void RiskClientSocket::ChooseArmyMoveCount(int maxCount)
{
	Json::Value params;
	params["maxCount"] = maxCount;
	SendCommand("game-chooseArmyMoveCount", params);
}

void RiskClientSocket::Fortify()
{
	SendCommand("game-fortify", Json::Value(Json::objectValue));
}
