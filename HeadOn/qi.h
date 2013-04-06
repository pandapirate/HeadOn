#ifndef _h_qi
#define _h_qi

#define HUMAN		1
#define COMPUTER	2
#define OTHER_PLAYER(player)	(3-player)

#define SPACE		0
#define BLOCK		-1

#define NULL		0

class Move;
class MoveList;
class Qi;

class Move
{
public:
	int		xf, yf;			// from here x, y; 0 <= x< size, 0 <= y < size
	char    direction;		// 'l - left(x-1); 'r' - right(x+1); 'u' - up(y+1); 'd' - down(y-1)

	int		xt, yt;			// move to there
	int     results;		// move results: -1 - the move failed, >= 0 -- how many the move eat.
	int		xp[4], yp[4];	// the locations of being eated

	Move	*next;
	Move	*prev;

	Move();
	Move(int x, int y, char dir, int points);

	void checkCapture(Qi *qi, int player, bool make);
	bool makeMove(Qi *qi, int player, bool make);
};

class MoveList
{
public:
	int		count;
	Move	*head;
	Move	*tail;
	
	MoveList();
	~MoveList();

	void addMove(int x, int y, char dir, int point);
	void delMove();
	MoveList *getMovesAfter(Qi *qi, int player);
};

class Qi
{
public:
	int		tiles[6][6];
	int		size;
	int     depth;
	time_t  seconds;
	Move	move;
	Move	lastMove;

	Qi(int n, int level);

	int remainPiecs(int player);
	MoveList *getMoves(int player);
	bool endCase(int player);

	int minmax_value(bool minmax, int player, int level, MoveList *moves, int points);

	Move *computerMove(int player);
	Move *computerMove();
};

#endif
