# Simple-API

API wrapper for the (Co-Engine)[https://github.com/dwhenry/co-engine] gem.


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

Get a quick summary of games being played, games won and games lost of the current player.

```
GET '/games', { auth_token: <auth_token> }
```
