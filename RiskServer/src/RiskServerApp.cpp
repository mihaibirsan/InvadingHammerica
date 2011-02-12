#include <stdio.h>
#include <signal.h>
#include <ListenSocket.h>
#include "RiskServerHandler.h"
#include "RiskClientSocket.h"

static	int m_quit = 0;

void sigint(int s) /* save+quit */
{
	m_quit++;
}

void sighup(int s) /* quit */
{
	m_quit++;
}

void sigusr1(int s) /* save */
{
}

void sigusr2(int s) /* reset all */
{
}

void sigpipe(int s)
{
}

void siginit(void)
{
	signal(SIGINT, (__sighandler_t)sigint);
	signal(SIGHUP, (__sighandler_t)sighup);
	signal(SIGUSR1, (__sighandler_t)sigusr1);
	signal(SIGUSR2, (__sighandler_t)sigusr2);
	signal(SIGPIPE, (__sighandler_t)sigpipe);
}

int main()
{
	RiskServerHandler h;
	ListenSocket<RiskClientSocket> l(h);
	siginit();

	if (l.Bind(8123))
	{
		printf("Unable to bind to listening port.\n");
		exit(-1);
	}

	h.Add(&l);

	while (!m_quit)
	{
		h.Select(1,0);
	}
}
