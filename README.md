# Simple-API

API wrapper for the [Co-Engine](https://github.com/dwhenry/co-engine) gem.


## Creating a user

```
POST '/register', { name: <user name>, password: <user password> }
```

## Request a auth-token

The auth token is used for user authentication throughout the system.

```
POST '/signin', { name: <user name>, password: <user password> }
```

The respose body will contain a JSON encoded auth token. The auth-token is valid for up to 4 hours.
 
```
{
  'status' => 'success',
  'auth_token' => '<auth token>'
}
```

Once obtained the auth token needs to be passed with each request. It can be passed as either a _"auth_token"_ query 
param or a _"AUTH_TOKEN"_ header  

## Creating a game

Game creation takes an optional player field which specifies the number of players spots in the game - defaults to 4.

All of the following requests will result in a new game being created.

```
POST '/games', { players: <player count>, auth_token: <auth_token> }
```

The response object contains the following key pieces of information:

* **Game ID** - required when making game moves in the future.
* **Game Data** - game view for the current player.
* **Actions** - list of actions the current player can undertake.

## Player statistics

Get a summary of games being played, games won and games lost of the current player.

```
GET '/games', { auth_token: <auth_token> }
```

The response object has the following JSON format:

```
{
  "playing" => 1,
  "won" => 3,
  "lost" => 2,
  "wainting_for_players" => 1,
  "can_be_joined" => 12
}
```

## Players games by state

Get a list of game the current player is in or can join.

```
GET '/games/<state>', { auth_token: <auth_token> }
```

Where state is one of playing, won, lost, waiting_for_players or can_be_joined.

The response object has the following JSON format:

    {
      <state> => [
        { "id" => "uuid", "max_players" => 4, "players" => [ "David", "Fred", "John" ], "winner" => nil },
        ...
      ]
    }


## Performing an action

Send the action to be performed to the CoEngine

The request should be in the format:

```
GET '/games/<state>', { auth_token: <auth_token>, perform: <action to be performed>, args: <optional args to be passed with the action> }
```

The below table list action and required args for each.

| Game State               | Action        | Args                                |
|--------------------------|---------------|-------------------------------------|
| WaitingForPlayers        | Join          |                                     |
| InitialTileSelection     | pick_tile     | tile_index                          |
| InitialTileSelection     | move_tile     | tile_position                       |
| InitialTileSelection     | finalize_hand |                                     |
| TileSelection            | pick_tile     | tile_index                          |
| GuessTile                | guess         | player, tile_position, color, value |
| FinaliseTurnOrGuessAgain | guess         | player, tile_position, color, value |
| FinaliseTurnOrGuessAgain | move_tile     | tile_position                       |
| FinaliseTurnOrGuessAgain | finalize_hand |                                     |
| FinaliseTurn             | move_tile     | tile_position                       |
| FinaliseTurn             | finalize_hand |                                     |

### Limitations

**finalize_hand** only appears as an action for InitialTileSelection once the user has selected the required amount of tiles 


### Action arguements

* **pick_tile->tile_index:** refers to the position of the tile on the game board, each tile is assigned an initial 
  position which does not chnage.
* **move_tile->tile_position:** tile movement is achieved by repeatedly swapping the position of any two tiles 
  (assuming they can be swapped). The tile_position is the lower index of the tile you want to swap.
* **guess->player:** this is the name of the player whose hand you want to pick a tile from.

