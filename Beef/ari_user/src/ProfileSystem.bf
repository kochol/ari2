using System;
using System.Threading;
using ari.net;
using curl;
using System.Collections;
using ari.io;
using ari.en;
using Atma;

namespace ari.user
{
	public delegate void dOnLoggedIn();
	public delegate void dOnHttpFailed(Easy.ReturnCode err);

	public delegate void dOnPlayerData(Player player);

	public delegate void dOnJoinedLobby(Lobby lobby);

	public delegate void dOnGameList(GameList games);

	public class ProfileSystem: AriSystem
	{
		private String ServerAddress = null ~ delete _;
		private HttpClientService http_client;
		List<String> headers = new List<String>() ~ DeleteContainerAndItems!(_);
		bool isLoggedIn = false;
		float sendAutoJoinAgain = -1;

		// player id <=> name dictionary
		Dictionary<int64, String> playerNames = new Dictionary<int64, String>() ~ {
			for (var kv in _)
			{
				delete kv.value;
			}
			delete _;
		};

		// Callbacks
		public dOnLoggedIn OnLoggedIn = null ~ delete _;
		public dOnHttpFailed OnLoginFailed = null ~ delete _;
		public dOnLoggedIn OnRegistered = null ~ delete _;

		public dOnPlayerData OnPlayerData = null ~ delete _;
		public dOnHttpFailed OnHttpFaild = null ~ delete _;

		public dOnJoinedLobby OnJoinedLobby = null ~ delete _;

		// Constructor
		public this(String server_address, HttpClientService _http_client)
		{
			ServerAddress = new String(server_address);
			http_client = _http_client;
		}

		protected override void Update(World _world, float _elapsed)
		{
			base.Update(_world, _elapsed);
			if (sendAutoJoinAgain > 0)
			{
				sendAutoJoinAgain -= _elapsed;
				if (sendAutoJoinAgain <= 0)
					AutoJoinToLobby();
			}
		}

		void OnLogin(HttpResponse response)
		{
			if (response.Status == .Ok && response.StatusCode == 200)
			{
				Login(response.Body);
				OnLoggedIn();
			}
			else
			{
				let s = scope String();
				s.AppendF("{} {}", response.Status, response.StatusCode);
				Logger.Error(s);
				if (OnLoginFailed != null)
					OnLoginFailed(response.Status);
			}
			response.Dispose();
		}

		public void Login(String _token)
		{
			let token = new String();
			token.Append("Authorization: ", "Bearer ", _token);
			headers.Add(token);

			let ct = new String();
			ct.Append("Content-Type: application/json; charset=utf-8");
			headers.Add(ct);

			http_client.session.SetHeaders(headers);
			isLoggedIn = true;
		}

		public void Login()
		{
			HttpRequest login = .();
			login.Url = new String(ServerAddress);
			login.Url.AppendF("auth/{}/", Io.GetDeviceID());
#if BF_PLATFORM_WINDOWS
			login.Url.Append("Windows/");
#elif BF_PLATFORM_LINUX
			login.Url.Append("Linux/");
#elif BF_PLATFORM_ANDROID
			login.Url.Append("Android/");
#endif
			let os = scope OperatingSystem();
			os.ToString(login.Url);

			login.OnRequestDone = new => OnLogin;

			http_client.AddRequest(ref login);
		}

		public void Login(String username, String password)
		{
			// clear the last headers
			ClearAndDeleteItems(headers);
			http_client.session.SetHeaders(null);

			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.AppendF("auth/{}/{}", username, password);
			req.OnRequestDone = new => OnLogin;
			http_client.AddRequest(ref req);
		}

		public bool IsLoggedIn()
		{
			return isLoggedIn;
		}

		void OnGetPlayerDataCB(HttpResponse res)
		{
			if (res.Status == .Ok && res.StatusCode == 200)
			{
				switch (JsonConvert.Deserialize<Player>(res.Body))
				{
				case .Err:
					Logger.Error("Error parsing GetPlayerData");
				case .Ok(let val):
					if (OnPlayerData != null)
					{
						OnPlayerData(val);
					}
					else
					{
						delete val;
					}
				}
			}
			else
			{
				let s = scope String();
				s.AppendF("{} {}", res.Status, res.StatusCode);
				Logger.Error(s);
				if (OnHttpFaild != null)
					OnHttpFaild(res.Status);
			}
			res.Dispose();
		}

		public void GetPlayerData()
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.Append("player");
			req.OnRequestDone = new => OnGetPlayerDataCB;
			http_client.AddRequest(ref req);
		}

		void OnAutoJoinToLobbyCB(HttpResponse res)
		{
			if (res.StatusCode == 200)
			{
				// We found a lobby to join
				Lobby lobby = new Lobby();
				switch (JsonConvert.Deserialize<Lobby>(lobby, res.Body))
				{
				case .Err:
					Logger.Error("Error parse JSON for AutoJoinToLobby");
					delete lobby;
				case .Ok:
					if (OnJoinedLobby != null)
					{
						OnJoinedLobby(lobby);
					}
					else
					{
						delete lobby;
					}
				}
			}
			else if(res.StatusCode == 204)
			{
				// we have to check again in next 3 seconds
				sendAutoJoinAgain = 3;
			}
			else
			{
				let s = scope String();
				s.AppendF("{} {}", res.Status, res.StatusCode);
				Logger.Error(s);
				if (OnHttpFaild != null)
					OnHttpFaild(res.Status);
			}
			res.Dispose();
		}

		public void AutoJoinToLobby()
		{
			sendAutoJoinAgain = -1;
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.Append("player/lobby");
			req.OnRequestDone = new => OnAutoJoinToLobbyCB;
			http_client.AddRequest(ref req);
		}

		public void CancelAutoJoinToLobby()
		{
			sendAutoJoinAgain = -2;
		}

		void OnRegisterCB(HttpResponse res)
		{
			if (res.StatusCode == 200)
			{
				if (OnRegistered != null)
					OnRegistered();
			}
			else
			{
				let s = scope String();
				s.AppendF("{} {}", res.Status, res.StatusCode);
				Logger.Error(s);
				if (OnHttpFaild != null)
					OnHttpFaild(res.Status);
			}
			res.Dispose();
		}

		public void Register(String userName, String password)
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.AppendF("auth/register/{}/{}/{}", Io.GetDeviceID(), userName, password);
			req.OnRequestDone = new => OnRegisterCB;
			http_client.AddRequest(ref req);
		}

		public void GetGames(int32 offset, int32 count, dOnGameList onGameList, dOnHttpFailed onFailed)
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.AppendF("player/games/{}/{}", offset, count);
			req.OnRequestDone = new (res) => {
				if (res.StatusCode == 200)
				{
					var games = new GameList();
					JsonConvert.Deserialize<List<Game>>(games.Games, res.Body);
					if (onGameList != null)
					{
						onGameList(games);
					}
					else
						delete games;
				}
				else if (res.StatusCode == 204)
				{
					// no games yet
					if (onGameList != null)
					{
						var games = new GameList();
						onGameList(games);
					}
				}
				else
				{
					let err = scope String();
					err.AppendF("Can not get player games {} {}", res.Status, res.StatusCode);
					Logger.Error(err);
					if (onFailed != null)
					{
						onFailed(res.Status);
					}
				}
				res.Dispose();
				delete onFailed;
				delete onGameList;
			};
			http_client.AddRequest(ref req);
		}

		public String GetPlayerName(int64 player_id)
		{
			if (playerNames.ContainsKey(player_id))
			{
				return playerNames[player_id];
			}
			let playerName = new String();
			playerNames.Add(player_id, playerName);

			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.AppendF("player/name/{}", player_id);
			req.OnRequestDone = new (res) => {
				if (res.StatusCode == 200)
				{
					playerName.Set(res.Body);
				}
				else
				{
					playerName.Set("Error not found");
				}
				res.Dispose();
			};
			http_client.AddRequest(ref req);

			return playerName;
		}

		public void ServerStartGame(int64 lobby_id)
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.AppendF("server/game_start/{}", lobby_id);
			http_client.AddRequest(ref req);
		}

		public void ServerGetLobby(int64 lobby_id, dOnJoinedLobby _OnGetLobby)
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.AppendF("server/get_lobby/{}", lobby_id);
			req.OnRequestDone = new (res) => {
				if (res.StatusCode == 200)
				{
					switch (JsonConvert.Deserialize<Lobby>(res.Body))
					{
					case .Err:
						Logger.Error("Error parsing lobby response");
					case .Ok(let val):
						if (_OnGetLobby != null)
						{
							_OnGetLobby(val);
							delete _OnGetLobby;
						}
						else
						{
							delete val;
						}
					}
				}
				res.Dispose();
			};
			http_client.AddRequest(ref req);
		}

		public void ServerUploadReplay(int64 game_id, uint8* data, int32 size, OnRequestDoneDelegate OnDone)
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.AppendF("server/save_replay/{}", game_id);
			req.FileData = data;
			req.FileSize = size;
			req.Verb = .Put;
			req.OnRequestDone = OnDone;
			http_client.AddRequest(ref req);
		}

		public void ServerSaveGame(Game game, OnRequestDoneDelegate OnDone)
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.Append("server/save_game");
			for (var t in game.teams)
			{
				for (var p in t)
				{
					p.score.Replace('\"', '\'');
				}
			}
			var val = new String();
			req.Verb = .Post;
			if (JsonConvert.Serialize<Game>(game, val))
			{
				req.Body = val;
			}
			req.OnRequestDone = OnDone;
			http_client.AddRequest(ref req);
		}

		public void DownloadReplay(int64 game_id, OnRequestDoneDelegate OnDone)
		{
			HttpRequest req = .();
			req.Url = new String(ServerAddress);
			req.Url.RemoveFromEnd(4);
			req.Url.AppendF("replays/{}.zip", game_id);
			req.OnRequestDone = OnDone;
			http_client.AddRequest(ref req);
		}
	}
}
