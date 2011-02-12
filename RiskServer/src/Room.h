/*
 * Room.h
 *
 *  Created on: Feb 4, 2011
 *      Author: mihaibirsan
 */

#ifndef ROOM_H_
#define ROOM_H_

#include <Thread.h>
#include <json/json.h>
#include "RiskClientSocket.h"


class RiskClientSocket;

class Room : public Thread
{
public:
	Room();
	~Room();

	virtual void Run();

	void HandleMessage(RiskClientSocket&, Json::Value&);

	void AddClient(RiskClientSocket*);
	void RemoveClient(RiskClientSocket*);
	bool IsAvailable();
	int  GetClientCount();

	void BroadcastStateData();
	void BroadcastRoomStateData();
	void BroadcastGameStateData();

	void Sleep();
	void Wakeup();

	int id;
	std::string name;
	std::string GetPlayerNames();

	bool gameStarted;

	Json::Value territories;

private:
	std::list<RiskClientSocket*> clients;
	Semaphore m_sem;
};

#endif /* ROOM_H_ */
