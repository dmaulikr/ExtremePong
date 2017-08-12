# ExtremePong

Re-imagined multiplayer pong. But extreme.

MVP Plan:

- Two players, one device
- Players bounce ball back and forth 
- If a player fails to bounce the ball back and the ball reaches their "goal", that player loses the round
- The goals are smaller rectangular portions of the ends of the screen

- To bounce balls back and forth, players create a paddle by swiping on the screen (limited only to their half of the screen)
- The direction of their swipe creates the paddle in that direction
- The start point of the swipe will correspond to the position of the paddle via its first endpoint
- Paddle length is static and has nothing to do with length of swipe
- Can only have up to two paddles on a player's side at any given time
- Once a paddle is created it cannot be removed or changed until a ball collides with it
- When the paddle disappears due to a ball collision, the player can then place another paddle
- First to win 5 rounds wins the game

- Power-ups will randomly spawn at the center of the screen and the first to drag the power-up back to their goal receives said power-up
- Power-ups may or may not include: Multiple balls, larger paddles, goal shield, extra paddle

- Similarly, power-downs(?) will randomly spawn at the center of the screen and a player can flick the power-down to the other player's goal. Upon reaching the goal, the other player receives a power-down or debuff.
- The other player can stop the power-down from reaching their goal by "catching" the power-down with their finger, and can then flick the power-down back towards the opposite player. This can go on until the power-down actually reaches a player's goal space
- Power-downs may or may not include: smaller paddles, minus one paddle, larger goal space

Nice to have features:

- Higher Production Art Assets
- Sound Assets
- Visually Dynamic Backgrounds
- Graphical effects
- Obstacles in play space
- Game Center integration. Ideally for multiplayer. Possibly for achievements?