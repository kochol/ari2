using System.Collections;
using System;
using Atma;

namespace ari.user
{
	[Serializable]
	class Game
	{
		public int64 id;

		public List<List<PlayerScore>> teams = null ~ {
			if (_ != null)
			{
				for (var value in _)
					DeleteContainerAndItems!(value);
				delete _;
			}
		};

		public int32 winnerTeamId;

		public String playTime = null ~ delete _;

		public String version = null ~ delete _;

		public double gameDuration;

		public String playTimeShort = null ~ delete _;

		public void ParsePlayTime()
		{
			// parse the y/m/d/h:m:s
			String tmp = scope String();
			tmp.Set(playTime);
			tmp.RemoveToEnd(4);
			int year = int.Parse(tmp);
			tmp.Clear();
			tmp.Set(playTime);
			tmp.RemoveToEnd(7);
			tmp.Remove(0, 5);
			int month = int.Parse(tmp);
			tmp.Clear();
			tmp.Set(playTime);
			tmp.RemoveToEnd(10);
			tmp.Remove(0, 8);
			int day = int.Parse(tmp);
			tmp.Clear();
			tmp.Set(playTime);
			tmp.RemoveToEnd(13);
			tmp.Remove(0, 11);
			int hour = int.Parse(tmp);
			tmp.Clear();
			tmp.Set(playTime);
			tmp.RemoveToEnd(16);
			tmp.Remove(0, 14);
			int minute = int.Parse(tmp);
			tmp.Clear();
			tmp.Set(playTime);
			tmp.RemoveToEnd(19);
			tmp.Remove(0, 17);
			int second = int.Parse(tmp);

			DateTime dt = .(year, month, day, hour, minute, second);
			let dif = DateTime.UtcNow.Subtract(dt);

			playTimeShort = new String();

			if (dif.Days > 3)
			{
				dt.ToShortDateString(playTimeShort);
			}
			else if (dif.Days > 1)
			{
				playTimeShort.AppendF("{} days ago", dif.Days);
			}
			else if (dif.Days == 1)
			{
				playTimeShort.Set("Yesterday");
			}
			else if (dif.Hours > 1)
			{
				playTimeShort.AppendF("{} hours ago", dif.Hours);
			}
			else if (dif.Minutes > 1)
			{
				playTimeShort.AppendF("{} minutes ago", dif.Minutes);
			}
			else
			{
				playTimeShort.AppendF("{} seconds ago", dif.Seconds);
			}
		}
	}
}
