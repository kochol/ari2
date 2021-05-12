using System;
using System.Threading;

namespace ari.core
{
	// Inspired from https://github.com/dbittman/waitfree-mpsc-queue project
	class MpScQueue<T>
	{
		public class MpScQueueBin
		{
			public int32 Capacity => _max;
			public int32 Count => _count;
			public MpScQueueBin Next = null ~ delete _;
			public MpScQueueBin Prev;

			int32 _count;
			int32 _head;
			int32 _tail;
			int32 _max;
			T[] _buff;

			[AllowAppend]
			public this(int32 capacity = 16, MpScQueueBin prev = null)
			{
				let _capacity = (((capacity) + (15)) & ((~0) & (~(15)))); // align & mask to 15

				let buff = append T[_capacity];
				_max = _capacity;
				_buff = buff;
				Prev = prev;
				Interlocked.Fence(.Release);
			}

			public bool Push(ref T item, ref int32 d_head)
			{
				Runtime.Assert(item != default, "This queue can not store null or 0 values.");
				let count = Interlocked.Add(ref _count, 1, .Acquire);
				if (count > _max)
				{
					// Queue is full
					Interlocked.Sub(ref _count, 1, .Release);
					return false;
				}

				/* increment the head, which gives us 'exclusive' access to that element */
				let head = Interlocked.Add(ref _head, 1, .AcqRel) - 1;
				d_head = head;
				let rv = Interlocked.Exchange(ref _buff[head % _max], item, .Release);
				Runtime.Assert(rv == default);

				return true;
			}

			public bool TryPop(ref T item)
			{
				let ret = Interlocked.Exchange(ref _buff[_tail], default, .Acquire);
				if (ret == default)
					return false;

				if (++_tail >= _max)
					_tail = 0;
				let r = Interlocked.Sub(ref _count, 1, .Release);
				Runtime.Assert(r >= 0);
				item = ret;
				return true;
			}

		} // MpScQueueBin

		MpScQueueBin _head;
		MpScQueueBin _pop_data;
		MpScQueueBin _push_data;
		Monitor _monitor = new Monitor() ~ delete _;

		public this(int32 capacity = 16)
		{
			let data = new MpScQueueBin(capacity);
			_head = data;
			_pop_data = data;
			_push_data = data;
		}

		public ~this()
		{
			delete _head;
		}

		public void Push(ref T item, ref MpScQueueBin bin, ref int32 head)
		{
			let push_data = Volatile.Read(ref _push_data);
			var data = push_data;
			var last_data = data;
			int32 maxCap = 16;
			while (data != null)
			{
				if (data.Push(ref item, ref head))
				{
					bin = data;
					Volatile.Write(ref _push_data, data);
					return;
				}
				let data_next = Volatile.Read(ref data.Next);
				if (data_next == null)
					last_data = data;
				if (data.Capacity > maxCap)
					maxCap = data.Capacity;
				data = data_next;
			}
			data = _head;
			while (data != push_data)
			{
				if (data.Push(ref item, ref head))
				{
					bin = data;
					Volatile.Write(ref _push_data, data);
					return;
				}
				if (data.Capacity > maxCap)
					maxCap = data.Capacity;
				data = Volatile.Read(ref data.Next);
			}

			// Create a new bin
			_monitor.Enter();
			if (last_data.Next == null)
			{
				let new_bin = new MpScQueueBin(maxCap * 2, last_data);
				Volatile.Write(ref last_data.Next, new_bin);
			}
			Volatile.Write(ref _push_data, last_data.Next);
			_monitor.Exit();
			if (!last_data.Next.Push(ref item, ref head))
			{
				Push(ref item, ref bin, ref head);
			}
			bin = last_data.Next;
		}

		public bool TryPop(ref T item)
		{
			var data = _pop_data;
			while (data != null)
			{
				if (data.TryPop(ref item))
				{
					_pop_data = data;
					return true;
				}
				data = data.Next;
			}
			data = Volatile.Read(ref _head);
			while (data != _pop_data)
			{
				if (data.TryPop(ref item))
				{
					_pop_data = data;
					return true;
				}
				data = data.Next;
			}
			return false;
		}

		public void Reset()
		{
			_push_data = _pop_data = _head;
		}

	} // MpScQueue<T>
}
