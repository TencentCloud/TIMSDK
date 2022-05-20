using System;

namespace com.tencent.imsdk.unity.callback
{
    public class CallbackConvert
    {
        public int code;
        public string type;
        public string data;

        public string user_data;

        public string desc;

        public int index = 0;

        public int cur_size = 0;

        public int total_size = 0;

        public string group_id = "";

        public int conv_event = 0;

        public ulong next_seq = 0;

        public bool is_finished = true;

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