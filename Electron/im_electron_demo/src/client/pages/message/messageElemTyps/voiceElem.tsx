import React from "react";
import { useState } from "react";
import { useRef } from "react";
import ReactAudioPlayer from "react-audio-player";
import withMemo from "../../../utils/componentWithMemo";

const VoiceElem = (props: any): JSX.Element => {
    const audioRef = useRef(null)
    const [playing,setPlaying] = useState(false)
    
    const item = (props) => {
        
        return (
                <div className="message-view__item--voice" >
                    {/* <span className={`message-view__item--voice___icon ${playing ? 'playing' : ''}`}></span>
                    <span className="message-view__item--voice___time">{props.sound_elem_file_time}"</span>
                    <audio src={props.sound_elem_url} ref={audioRef}></audio> */}
                    <ReactAudioPlayer
                        src={props.sound_elem_url}
                        autoPlay={false}
                        controls = {true}
                        ref ={ audioRef }
                        crossOrigin = { 'https://cos.ap-shanghai.myqcloud.com' }
                    />
                </div>
        )
    };
   
    return item(props);
}

export default withMemo(VoiceElem);