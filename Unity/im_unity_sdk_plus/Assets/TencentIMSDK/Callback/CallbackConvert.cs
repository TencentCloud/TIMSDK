using System;
using System.Collections.Generic;
using UnityEngine;

namespace com.tencent.imsdk.unity.callback
{
    public class CallbackConvert
    {
        public int code { get; set; }
        public string type { get; set; }
        public string data { get; set; }

        public string user_data { get; set; }

        public string desc { get; set; }

        public int index { get; set; } = 0;

        public int cur_size { get; set; } = 0;

        public int total_size { get; set; } = 0;

        public string group_id { get; set; } = "";

        public int conv_event { get; set; } = 0;

        public ulong next_seq { get; set; } = 0;

        public bool is_finished { get; set; } = true;

        public CallbackConvert() {}

        public CallbackConvert(int code,string type, string data, string user_data, string desc = "",int index = 0 , int cur_size = 0, int total_size = 0,string group_id = "",int conv_event = 0, ulong next_seq = 0, bool is_finished = true)
        {
            this.code = code;
            this.data = data;
            this.type = type;
            this.user_data = user_data;
            this.desc = desc;
            this.index = index;
            this.cur_size  = cur_size;
            this.total_size = total_size;
            this.group_id = group_id;
            this.conv_event = conv_event;
            this.next_seq = next_seq;
            this.is_finished = is_finished;
        }
    }
}