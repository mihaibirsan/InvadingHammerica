/*
 * RiskServerHandler.h
 *
 *  Created on: Feb 4, 2011
 *      Author: mihaibirsan
 */

#ifndef RISKSERVERHANDLER_H_
#define RISKSERVERHANDLER_H_

#include <json/json.h>
#include <SocketHandler.h>
#include "Room.h"

class RiskClientSocket;

class RiskServerHandler : public SocketHandler
{
public:
	RiskServerHandler();
	~RiskServerHandler();

	void HandleMessage(RiskClientSocket&, const std::string&);
	void RemoveClientFromRoom(RiskClientSocket&);

	void BroadcastLobbyStateData();

private:
	Json::Reader jsonReader;
	Json::FastWriter jsonWriter;
	std::list<Room*> rooms;
};

#endif /* RISKSERVERHANDLER_H_ */
