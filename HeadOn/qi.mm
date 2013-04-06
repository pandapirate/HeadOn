
#include <stdlib.h>
#include <time.h>
#include "qi.h"

#define WIN_VALUE  5000
#define MAX_VALUE  100000

#define TIMEOUT	   8

static char direction[4] = {'l', 'r', 'u', 'd'};

Move::Move(int x, int y, char dir, int points)
{
	xf = x;
	yf = y;
	direction = dir;
	results = points;

	switch (direction)
	{
	case 'l':
		xt = xf - 1;
		yt = yf;
		break;

	case 'r':
		xt = xf + 1;
		yt = yf;
		break;

	case 'u':
		xt = xf;
		yt = yf + 1;
		break;

	case 'd':
		xt = xf;
		yt = yf - 1;
		break;

	case 'n':
		results = 0;
		break;

	default:
		results = -1;
		break;
	}

	next = NULL;
	prev = NULL;
}

Move::Move()
{
	Move(0,0,'n',0);
}

void Move::checkCapture(Qi *qi, int player, bool make)
{
	int other_player = OTHER_PLAYER(player);
	int i, player_count, other_count, find[6];

	qi->tiles[xf][yf] = SPACE;
	qi->tiles[xt][yt] = player;
	
	results = 0;
	
	player_count = 1;
	other_count = 0;

	for ( i = xt + 1; i < qi->size; i++)
	{
		if (qi->tiles[i][yt] != player)
			break;
		player_count++;
	}

	for (; i < qi->size; i++)
	{
		if (qi->tiles[i][yt] != other_player)
			break;

		find[other_count] = i;
		other_count++;
	}

	for ( i = xt - 1; i >= 0; i--)
	{
		if (qi->tiles[i][yt] != player)
			break;
		player_count++;
	}

	for (; i >= 0; i--)
	{
		if (qi->tiles[i][yt] != other_player)
			break;

		find[other_count] = i;
		other_count++;
	}

	if (player_count > other_count)
	{
		for (i = 0; i < other_count; i++)
		{
			xp[i] = find[i];
			yp[i] = yt;
			if (make)
			{
				qi->tiles[find[i]][yt] = SPACE;
			}
		}
		results = other_count;
	}

	player_count = 1;
	other_count = 0;

	for ( i = yt + 1; i < qi->size; i++)
	{
		if (qi->tiles[xt][i] != player)
			break;
		player_count++;
	}

	for (; i < qi->size; i++)
	{
		if (qi->tiles[xt][i] != other_player)
			break;

		find[other_count] = i;
		other_count++;
	}

	for ( i = yt - 1; i >= 0; i--)
	{
		if (qi->tiles[xt][i] != player)
			break;
		player_count++;
	}

	for (; i >= 0; i--)
	{
		if (qi->tiles[xt][i] != other_player)
			break;

		find[other_count] = i;
		other_count++;
	}

	if (player_count > other_count)
	{
		for (i = 0; i < other_count; i++)
		{
			xp[results+i] = xt;
			yp[results+i] = find[i];
			if (make)
			{
				qi->tiles[xt][find[i]] = SPACE;
			}
		}
		results += other_count;
	}

	if (!make)
	{
		qi->tiles[xf][yf] = player;
		qi->tiles[xt][yt] = SPACE;
	}
}

bool Move::makeMove(Qi *qi, int player, bool make)
{
	if (direction == 'n')
		return true;

	if (xf >= 0 && xf < qi->size && yf >= 0 && yf < qi->size && xt >= 0 && xt < qi->size && yt >= 0 && yt < qi->size)
	{
		if (qi->tiles[xf][yf] == player && qi->tiles[xt][yt] == SPACE)
		{
			checkCapture(qi, player, make);
			return true;
		}
	}

	results = -1;
	return false;
}

MoveList::MoveList()
{
	count = 0;
	head = 0;
	tail = 0;
}

MoveList::~MoveList()
{
	Move *m = head;

	while (m)
	{
		Move *n = m->next;
		delete m;
		m = n;
	}
}

void MoveList::addMove(int x, int y, char dir, int point)
{
	Move *m = new Move(x, y, dir, point);

	m->prev = tail;

	if (tail)
	{
		tail->next = m;
	}
	else
	{
		head = m;
	}

	tail = m;
	count++;
}

void MoveList::delMove()
{
	Move *m = tail;

	tail = m->prev;
	delete m;

	if (!tail)
	{
		head = NULL;
	}
	else
	{
		tail->next = NULL;
	}

	count--;
}

MoveList *MoveList::getMovesAfter(Qi *qi, int player)
{
	int temp[6][6];

	for (int y = 0; y < qi->size; y++)
	{
		for (int x = 0; x < qi->size; x++)
		{
			temp[x][y] = qi->tiles[x][y];
		}
	}

	int simplayer = (count % 2 != 0)? OTHER_PLAYER(player) : player;
	Move *m = head;

	while (m)
	{
		m->makeMove(qi, simplayer, true);

		simplayer = OTHER_PLAYER(simplayer);
		m = m->next;
	}

	MoveList *moves = qi->getMoves(player);

	for (int y = 0; y < qi->size; y++)
	{
		for (int x = 0; x < qi->size; x++)
		{
			qi->tiles[x][y] = temp[x][y];
		}
	}

	return moves;
}

Qi::Qi(int n, int level)
{
	if (n > 6)
		n = 6;
	else if (n < 4)
		n = 4;

	for (int y = 0; y < n; y++)
	{
		for (int x = 0; x < n; x++)
		{
			if (y == 0)
			{
				tiles[x][y] = HUMAN;
			}
			else if (y == n-1)
			{
				tiles[x][y] = COMPUTER;
			}
			else
			{
				tiles[x][y] = SPACE;
			}
		}
	}

	if (n > 4)
	{	
		tiles[2][2] = BLOCK;
		if (n == 6)
		{
			tiles[3][3] = BLOCK;
		}
	}

	size = n;
	depth = level;

	move = Move(-1,-1,'n', 0);
	lastMove = Move(-1,-1,'n', 0);
}

int Qi::remainPiecs(int player)
{
	int remain = 0;
		
	for (int y = 0; y < size; y++)
	{
		for (int x = 0; x < size; x++)
		{
			if (tiles[x][y] == player)
			{
				remain++;
			}
		}
	}
	return remain;
}

MoveList *Qi::getMoves(int player)
{
	MoveList *moves = new MoveList();

	if (remainPiecs(player) >= 2)
	{
		for (int yf = 0; yf < size; yf++)
		{
			for (int xf = 0; xf < size; xf++)
			{
				for (int i = 0; i < 4; i++)
				{
					Move temp = Move(xf, yf, direction[i], 0);

					if (temp.makeMove(this, player, false))
					{
						moves->addMove(xf, yf, direction[i], temp.results);
					}
				}
			}
		}
	}

	return moves;
}

bool Qi::endCase(int player)
{
	bool end = false;
	MoveList *allMoves = getMoves(player);

	if (allMoves->count == 0)
	{
		end = true;
	}

	delete allMoves;

	return end;
}

int Qi::minmax_value(bool minmax, int player, int level, MoveList *moves, int points)
{
	MoveList *allMoves = moves->getMovesAfter(this, player);

	if (allMoves->count == 0)
	{
		delete allMoves;
		return (minmax?-WIN_VALUE:WIN_VALUE) * (depth - level);
	}
	
	if (level == depth)
	{
		delete allMoves;
		return points;
	}

	int value = (minmax?-MAX_VALUE:MAX_VALUE);
	Move *mv = allMoves->head;

	while (mv)
	{
		moves->addMove( mv->xf,  mv->yf,  mv->direction, mv->results);

		int c = mv->results * (depth - level)*10;
		int v = minmax_value(!minmax, OTHER_PLAYER(player), level+1, moves, (minmax ? points + c : points - c));

		if (minmax)
		{
			if (v > value) value = v;
		}
		else
		{
			if (v < value) value = v;
		}

		moves->delMove();
		mv = mv->next;

		if ((int)(time (NULL) - seconds) > TIMEOUT && value != -MAX_VALUE && value != MAX_VALUE)
		{
			break;
		}
	}

	delete allMoves;

	return value;
}

Move *Qi::computerMove(int player)
{
	MoveList *allMoves = getMoves(player);
	MoveList *moves = new MoveList();

	int value = -MAX_VALUE;
	Move *mv = allMoves->head;

	seconds = time (NULL);

	while (mv)
	{
		int c = mv->results * depth * 10;

		if (mv->xf == lastMove.xt && mv->xt == lastMove.xf &&
			mv->yf == lastMove.yt && mv->yt == lastMove.yf)
			c -= 5;
		else {
			int dd = 2*size;
			int other_player = OTHER_PLAYER(player);

			for (int y = 0; y < size; y++)
			{
				for (int x = 0; x < size; x++)
				{
					bool is_block = false;
					if (tiles[x][y] == other_player)
					{
						if (mv->xt == x) {
							if (mv->yt > y) {
								for (int i = y + 1; i < mv->yt; i++)
									if (tiles[x][i] == BLOCK) is_block = true;
							}
							else {
								for (int i = y - 1; i > mv->yt; i--)
									if (tiles[x][i] == BLOCK) is_block = true;
							}
						}
						else if (mv->yt == y) {
							if (mv->xt > x) {
								for (int i = x + 1; i < mv->xt; i++)
									if (tiles[i][y] == BLOCK) is_block = true;
							}
							else {
								for (int i = x - 1; i > mv->xt; i--)
									if (tiles[i][y] == BLOCK) is_block = true;
							}
						}

						if (!is_block) {
							int d = abs(mv->xt - x) + abs(mv->yt - y);
							if (d < dd)
								dd = d;
						}
					}
				}
			}

			c += 10 - dd;
		}

		moves->addMove(mv->xf,  mv->yf,  mv->direction, mv->results);
		int v = minmax_value(false, OTHER_PLAYER(player), 1, moves, c);

		if (v > value  || (v == value && rand() % 2 == 1))
		{
			value = v;
			move = Move(mv->xf,  mv->yf,  mv->direction, mv->results);
		}

		moves->delMove();
		mv = mv->next;

		if ((int)(time (NULL) - seconds) > TIMEOUT && value != -MAX_VALUE)
		{
			break;
		}
	}

	delete allMoves;
	delete moves;

	move.makeMove(this, player, true);
	lastMove = move;

	return &move;
}

Move *Qi::computerMove()
{
	return computerMove(COMPUTER);
}