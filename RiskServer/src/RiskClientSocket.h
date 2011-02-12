/*
 * RiskClientSocket.h
 *
 *  Created on: Feb 4, 2011
 *      Author: mihaibirsan
 */

#ifndef RISKCLIENTSOCKET_H_
#define RISKCLIENTSOCKET_H_

#include <TcpSocket.h>
#include "Room.h"

class Room;

class RiskClientSocket : public TcpSocket
{
public:
	RiskClientSocket(ISocketHandler&);
	virtual ~RiskClientSocket();

	void OnLine(const std::string&);
	void OnDisconnect();

	bool HasRoom();
	Room* GetRoom();
	void SetRoom(Room*);

	void SendCommand(const std::string&, const Json::Value&);

	void Hello();
	void GameBid();
	void GamePlaceArmies(int);
	void Battle();
	void ChooseDieCount(int);
	void SpendGhosts();
	void ChooseArmyMoveCount(int);
	void Fortify();

	int id;
	std::string name;
	std::string color;
	bool ready;
	int gold;
	int ghosts;
	int lastBid;

private:
	Json::Reader jsonReader;
	Json::FastWriter jsonWriter;
	Room* room;
};

int operator<(const RiskClientSocket& left, const RiskClientSocket& right);

#endif /* RISKCLIENTSOCKET_H_ */
