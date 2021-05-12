using System;
using System.Threading;
using ari.core;

namespace testEN
{
	class TestMpScQueue
	{
		struct debug_data
		{
			public bool Checked = false;
			public int32 Head;
			public MpScQueue<int32>.MpScQueueBin Bin;
		}

		const int _writers_count = 64;
		const int _max_val = 100000;
		Thread[] _writerThreads = null ~ delete _;
		Thread _readerThread = null;
		int32 _i = 0;
		MpScQueue<int32> _queue = new MpScQueue<int32>() ~ delete _;
		debug_data[] _checks = new debug_data[_max_val] ~ delete _;
		bool _run = true;

		void WriteThread()
		{
			while (true)
			{
				var i = Interlocked.Add(ref _i, 1, .Acquire);
				if (i >= _max_val)
					return;
				_queue.Push(ref i, ref _checks[i].Bin, ref _checks[i].Head);
			}
		}

		void ReadThread()
		{
			int32 i = 0;
			int32 c = 1;
			while(c < _max_val && _run)
			{
				if (_queue.TryPop(ref i))
				{
					if (_checks[i].Checked == true)
					{
						Console.Write(i);
						Console.Write("\t :D");
					}
					_checks[i].Checked = true;
					//if (i != c)
					{
						//Console.Write(i);
						//Console.Write("\t");
					}
					c++;
				}
			}

		}

		public void Run()
		{
			_writerThreads = new Thread[_writers_count];
			
			_readerThread = new Thread(new => ReadThread);
			_readerThread.Start(false);

			Thread.Sleep(20);

			for (int i = 0; i < _writers_count; i++)
			{
				_writerThreads[i] = new Thread(new => WriteThread);
				_writerThreads[i].Start(false);
			}

			_readerThread.Join(1000);
			_run = false;
			for (int i = 1; i < _max_val; i++)
			{
				if (!_checks[i].Checked)
				{
					let check = _checks[i];
					Console.WriteLine(i);
				}
			}
			_readerThread.Join();
			delete _readerThread;

			for (int i = 0; i < _writers_count; i++)
			{
				_writerThreads[i].Join();
				delete _writerThreads[i];
			}

		}
	}
}
