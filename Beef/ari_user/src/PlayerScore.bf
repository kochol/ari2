using System;
using Atma;

namespace ari.user
{
	[Serializable]
	class PlayerScore
	{
		public this()
		{

		}

		public this(int64 _playerId, String _score)
		{
			playerId = _playerId;
			score = _score;
		}

		public int64 playerId;

		public String score = null ~ delete _;
	}
}
