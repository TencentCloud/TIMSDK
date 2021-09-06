<template>
    <div class="container" :class="{
    size_12_9: plate === plateType.SIZE_12_9,
    size_9_6: plate === plateType.SIZE_9_6,
    size_6_4: plate === plateType.SIZE_6_4,
    }">
        <div class="title">{{title}}</div>
        <div class="description">
            <p>{{desc}}</p>
        </div>
        <!--===================================== 模版操作区 =====================================-->
        <div class="operatePanel">
            <!--=========================== 左操作区（选择卡片） ===========================-->
            <div class="leftPanelContainer" :style="{ 'background': (plate === plateType.SIZE_12_9) ? `url(${IMAGERESOURCES.leftPanel_12_9}) no-repeat` : `url(${IMAGERESOURCES.leftPanel_9_6}) top center no-repeat` }">
                <div class="upPanel">
                    <div class="cardThumb" v-for="(item, index) in leftPanelObj.upOptionData" :class="{activeUpCard: index === currentIndex, upFinished: item.isFinished}">
                        <div class="imgContainer">
                            <img :src="item.image" alt="" @click="updateCurrentIndex(index)"
                                 v-logs="{event: 'click',
                                          id: index,
                                          eleType: 'question',
                                          subType: 'image',
                                          content: item.image}">
                        </div>
                    </div>
                </div>

                <div class="cardInfo">
                    <ul class="cardRotary" ref="cardRotary">
                        <li v-for="(item, index) in cardRotaryList">
                            <img class="cardImage" :src="item"/>
                        </li>
                    </ul>
                    <img v-if="activeData.audio.length > 0"
                         class="cardAudio"
                         @click="playTestAudio"
                         :src="isPlayingAudio ? audioGif : audioImg"
                         v-logs="{event: 'click',
                                  id: `audio${activeData.index}`,
                                  eleType: 'question',
                                  subType: 'audio',
                                  content: activeData.audio}"
                    />
                </div>

                <div class="downPanel">
                    <div class="cardThumb" v-for="(item, index) in leftPanelObj.downOptionData" :class="{activeDownCard: index + 3 === currentIndex, downFinished: item.isFinished}">
                        <div class="imgContainer">
                            <img :src="item.image" alt="" @click = "updateCurrentIndex(index + 3)"
                                 v-logs="{event: 'click',
                                          id: index + 3,
                                          eleType: 'question',
                                          subType: 'image',
                                          content: item.image}">
                        </div>
                    </div>
                </div>
            </div>

            <!--=========================== 右操作区（填涂单词） ===========================-->
            <div class="rightPanel">
                <div v-for="(item, index) in optionData" :class="['answer', index < isFinishedNumber ? 'greenAnswer' : 'blueAnswer']" :style="columnStyleList[index]">
                </div>
                <div class="flexPanel"
                     columnIndex="columnIndex"
                     @touchstart="onColumnChooseStart($event, 'touch')"
                     @mousedown="onColumnChooseStart($event, 'mouse')"

                     @touchmove="onColumnChooseMove($event, 'touch')"
                     @mousemove="onColumnChooseMove($event, 'mouse')"

                     @touchend="onColumnChooseEnd($event, 'touch')"
                     @mouseup="onColumnChooseEnd($event, 'mouse')"

                    @touchcancel="onColumnChooseEnd($event, 'touch')"
                    @mouseleave="onColumnChooseEnd($event, 'mouse')">
                    <div class="column"
                         :class="{active: stashIndexList.indexOf(index) !== -1,
                                  hide: flattenTestOkList.indexOf(index) !== -1,
                                  twinkle: twinkleLetterIndex === index}"
                         ref="columnMap"
                         :columnIndex="index"
                         v-for="(item, index) in wordList"
                    >{{item}}</div>
                </div>
                <div v-show="!canControlAnswerArea" class="rightForbidPanel"></div>
            </div>
        </div>
        <clock-comp ref="clock" :timerNumber="timerNumber"
                    :userCanControl="userCanControl"
                    :isTestFinished="isTestFinished"
                    @startCountDown="startCountDown"
                    @pauseCountDown="pauseCountDown"
                    @countNumber="updateCountNumber"></clock-comp>
    </div>
</template>

<script>
    import {
        plateType,
        direction,
        IMAGERESOURCES
    } from './constants'
    import audioImg from './images/audio.png'
    import audioGif from './images/audio.gif'
    import clockComp from './components/clock'
    import {TweenLite} from 'gsap'
    import logMixin from '../../commonComp/vLog/mixin'

    const signalHandle = {
        flag: '@',
        isSignal(data) {
            return (
                typeof data === 'string' &&
                data[0] === this.flag
            )
        },
        // 去掉空格，防止信令转换成转换'+'
        wrap(data) {
            return (this.flag + JSON.stringify(data))
                .replace(/\s/g, '<%>')
        },
        parse(data) {
            if (this.isSignal(data)) {
                data = data.substr(1)
                    .replace(/<%>/g, ' ')
            }

            try {
                return JSON.parse(data)
            } catch(e) {
                return data
            }
        }
    }
    /**
     * IC011(点涂找词)
     */
    export default {
        name: "IC011",
        data() {
            return {
                title: '',
                desc: '',
                plateType: plateType,
                plate: plateType.SIZE_12_9,
                IMAGERESOURCES,
                // 所有的文字
                wordList: [],
                // 所有的选项内容
                optionData: [],
                // 所有还没有完成的选项的内容
                unDoneOptionData: [],
                // 当前已经做对题目的总量
                isFinishedNumber: 0,

                // 左侧题目区的选项内容
                leftPanelObj: {
                    upOptionData: [],
                    downOptionData: [],
                },

                // 当前是在对第几个进行操作
                currentIndex: 0,
                // 当前正在滑动经过的与元素的集合
                stashIndexList: [],
                // 历史所有stashIndexList的集合
                testOkList: [],
                // 用户是否正在拖拽答题中
                isChooseDraging: false,
                // 用户上一个选中的字母index
                lastPressIndex: -1,


                // 答案的样式集合
                columnStyleList: [],

                audioImg: audioImg,
                audioGif: audioGif,
                // 是否正在播放音频
                isPlayingAudio: false,
                curAudioObj: {
                    src: '',
                    id: '',
                },

                // 是否是预览模式
                isPreview: undefined,
                // 是否是老师端
                isMaster: undefined,
                // 兼容多贝教室ios9，音频播放时间默认为4s
                canPlayAudio: true,
                // 播放音频停止到播放下一次音频的间隔事件
                audioPlayDuration: undefined,
                // 间隔时间延迟
                timeOut: null,
                audioPlayer: null,

                // 倒计时总数
                timerNumber:0,
                canControlAnswerArea: false,
                // 倒计时的实时数字
                countNumber: 0,

                // 10秒提醒的延迟
                remindTimeout: null,
                twinkleLetterIndex: -1,

                // 是否所有的内容都答完了
                isTestFinished: false,

                // 需要轮训的卡片的数组
                cardRotaryList: [],
            }
        },
        mixins: [logMixin],
        components: {clockComp},
        props: {
            options: Object
        },
        computed: {
            // 当前被选中的选项对象
            activeData() {
                return this.optionData[this.currentIndex]
            },
            // 矩阵横竖数量
            matrixCount() {
                if (this.plate === plateType.SIZE_9_6) {
                    return {
                        columnNumber: 9,
                        lineNumber: 6,
                        totalNumber: 9 * 6,
                    }
                } else if (this.plate === plateType.SIZE_12_9) {
                    return {
                        columnNumber: 12,
                        lineNumber: 9,
                        totalNumber: 12 * 9,
                    }
                } else if (this.plate === plateType.SIZE_6_4) {
                    return {
                        columnNumber: 6,
                        lineNumber: 4,
                        totalNumber: 6 * 4,
                    }
                }
            },
            // 所有已经被选对的字母的数组扁平化
            flattenTestOkList() {
                if (this.testOkList.length > 0) {
                    return this.testOkList.reduce(function (a, b) { return a.concat(b)} );
                } else {
                    return []
                }
            },
            // 是预览模式或者是老师角色
            userCanControl() {
                return this.isPreview || this.isMaster
            },
        },
        watch: {
            'options': {
                immediate: true,
                deep: true,
                handler(val) {
                    if (val.config) {
                        this.initData(val)
                    }
                }
            },
            'options.config.isMaster': {
                immediate: true,
                handler(val) {
                    if(typeof(val) === 'undefined') {
                        this.isPreview = true
                    }
                    this.isMaster = val !== false
                },
            },
            'options.config.audioPlayDuration': {
                immediate: true,
                handler(val) {
                    console.log('lixin audioPlayDuration', val)
                    this.audioPlayDuration = val || 3000
                }
            },
            optionData: {
                immediate: true,
                deep: true,
                handler(val) {
                    this.unDoneOptionData = []
                    this.isFinishedNumber = 0
                    val.forEach(item => {
                        if (!item.isFinished) {
                            this.unDoneOptionData.push(item)
                        } else {
                            this.isFinishedNumber++
                        }
                    })

                    if (this.isFinishedNumber === val.length) {
                        this.hadFinishedTest()
                    }

                    if (this.optionData.length <= 3) {
                        this.leftPanelObj.upOptionData = this.optionData
                    } else if (this.optionData.length > 3 && this.optionData.length <= 6) {
                        this.leftPanelObj.upOptionData = this.optionData.slice(0, 3)
                        this.leftPanelObj.downOptionData = this.optionData.slice(3, this.optionData.length)
                    }
                }
            }
        },
        methods: {
            // 判断值是否为null
            isNull(tmp) {
               return !tmp && typeof(tmp) !== 'undefined' && tmp !== 0
            },
            // 用来将一维数组二维化，第一个参数是一维数组，第二个参数是单个子数组的长度
            dimensionsList(list, columnNumber) {
                let dimensionsList = []
                let row = list.length / columnNumber
                for (let i = 0; i < row; i++) {
                    dimensionsList.push(list.slice(i * columnNumber, (i + 1) * columnNumber))
                }
                return dimensionsList
            },
            // 初始化模版数据
            initData(options) {
                let self = this

                let configData = JSON.parse(JSON.stringify(options.config.data))
                this.title = configData && configData.topic_text
                this.desc = configData && configData.content_text
                this.plate = configData && configData.plate
                this.optionData = configData && configData.option
                this.wordList = configData && configData.words.split('')
                this.timerNumber = this.countNumber = Number(configData && configData.timer)

                this.wordList = this.wordList.filter((item) => {
                    return item !== ' '
                })
                if (this.wordList.length > this.matrixCount.totalNumber) {
                    this.wordList = this.wordList.slice(0, this.matrixCount.totalNumber)
                }

                if (this.optionData.length > 6) {
                    this.optionData = this.optionData.slice(0, 6)
                }

                // 发送题目数量的日志记录
                this.excNumLog(this.optionData.length)

                this.$nextTick(() => {
                    this.restoreCardRotary()
                })

                let wordDimensionList = []
                if (this.plate === plateType.SIZE_12_9 && this.wordList.length > 12 * 9) {
                    this.wordList.slice(0, 12 * 9)
                } else if (this.plate === plateType.SIZE_9_6 && this.wordList.length > 9 * 6) {
                    this.wordList.slice(0, 9 * 6)
                } else if (this.plate === plateType.SIZE_6_4 && this.wordList.length > 6 * 4) {
                    this.wordList.slice(0, 6 * 4)
                }
                wordDimensionList = this.dimensionsList(this.wordList, this.matrixCount.columnNumber)

                let insertWordToList = function(itemData) {
                    let startPosition = Number(itemData.start_position)
                    itemData.columnIndexList = [startPosition - 1]
                    if ( startPosition < 1 || startPosition > self.matrixCount.totalNumber) {
                        return
                    }
                    let startPositionIndex = startPosition - 1
                    let row = Math.floor(startPositionIndex / self.matrixCount.columnNumber)
                    let column = startPositionIndex % self.matrixCount.columnNumber
                    let textList = itemData.text.split('')
                    if (itemData.direction === 'horizontal') {
                        for(let flag = 0; flag < textList.length; flag++) {
                            if (column >= self.matrixCount.columnNumber) {
                                itemData.text = textList.slice(0, flag).join('')
                                break;
                            }
                            wordDimensionList[row][column] = textList[flag]
                            column++
                            itemData.columnIndexList.push(itemData.columnIndexList[itemData.columnIndexList.length - 1] + 1)
                        }
                        itemData.columnIndexList.pop()
                    } else if (itemData.direction === 'vertical') {
                        for(let flag = 0; flag < textList.length; flag++) {
                            if (row >= self.matrixCount.lineNumber) {
                                itemData.text = textList.slice(0, flag).join('')
                                break;
                            }
                            wordDimensionList[row][column] = textList[flag]
                            row++
                            itemData.columnIndexList.push(itemData.columnIndexList[itemData.columnIndexList.length - 1] + self.matrixCount.columnNumber)
                        }
                        itemData.columnIndexList.pop()
                    }
                }

                this.optionData.forEach((item, index) => {
                    item.index = index
                    // 表示这个单词是否已经做完了
                    item.isFinished = false

                    let textList = item.text.split('')
                    textList = textList.filter((text) => {
                        return text !== " "
                    })
                    item.text = textList.join('')

                    this.columnStyleList.push({
                        width: '',
                        height: '',
                        top: '',
                        left: '',
                    })

                    insertWordToList(item)
                })

                this.wordList = wordDimensionList.reduce(function (a, b) { return a.concat(b)});
            },

            // 播放音频
            playAudio(data) {
                this.curAudioObj.src = data.src
                this.curAudioObj.id = data.id
                if (this.isPreview) {
                    // 自己播放音频（适用于预览的时候）
                    if (!this.audioPlayer.ended) {
                        this.audioPlayer.pause()
                    }
                    this.audioPlayer.src = data.src
                    try {
                        this.audioPlayer.play()
                            .then(() => {
                                console.log('lixin IC009 playaudio OK')
                            }).catch((err) => {
                            console.log('lixin IC009 playaudio error1', err)
                        })
                    } catch(err) {
                        console.log('lixin IC009 playaudio error2', err)
                    }
                } else {
                    // 发送给底层去播放新的音频(直播的时候)
                    this.canPlayAudio && this.$emit('event', {
                        type: 'playAudio',
                        src: data.src,
                        id: data.id,
                        mode: data.mode,
                    })
                    if (data.mode === 'sound') {
                        clearTimeout(this.timeOut)
                        this.canPlayAudio = false
                        this.timeOut = setTimeout(() => {
                            this.canPlayAudio = true
                        }, this.audioPlayDuration)
                    }
                }
            },
            // 重置和翻页的时候用来停止音频播放
            pauseAudio() {
                if (this.isPreview) {
                    if (!this.audioPlayer.ended) {
                        this.audioPlayer.pause()
                    }
                } else {
                    if (!!this.curAudioObj.src) {
                        this.$emit('event', {
                            type: 'pauseAudio',
                            src: this.curAudioObj.src,
                            id: this.curAudioObj.id,
                        })
                    }
                }
                this.curAudioObj.src = ''
                this.curAudioObj.id = ''
            },

            updateCurrentIndex(index) {
                this.sendSignal('updateCurrentIndex', {index})
                this.updateCurrentIndexAction(index)
            },

            updateCurrentIndexAction(index) {
                if (this.currentIndex === index) {
                    return
                }
                this.currentIndex = index

                if (index <= 2) {
                    this.cardRotaryList[0] = this.optionData[index].image
                    if (this.$refs.cardRotary) {
                        TweenLite.to(this.$refs.cardRotary, 0.5, {
                            top: '0px',
                            onComplete: () => {
                                this.cardRotaryList = [].concat(['', this.optionData[index].image, ''])
                                this.$refs.cardRotary.style.top = '-189px'
                            }
                        })
                    }
                } else {
                    this.cardRotaryList[2] = this.optionData[index].image
                    if (this.$refs.cardRotary) {
                        TweenLite.to(this.$refs.cardRotary, 0.5, {
                            top: '-378px',
                            onComplete: () => {
                                this.cardRotaryList = [].concat(['', this.optionData[index].image, ''])
                                this.$refs.cardRotary.style.top = '-189px'
                            }
                        })
                    }
                }

                // 如果是可以操作做状态的话, 需要设置提醒时间
                this.canControlAnswerArea && this.setRemindTimeout()
                this.sendSignal('status')
            },

            // 播放音频
            playTestAudio() {
                if (this.isPlayingAudio) {
                    return
                }
                this.sendSignal('playTestAudio', {})
                this.playTestAudioAction()
            },

            playTestAudioAction() {
                this.isPlayingAudio = true
                this.playAudio({
                    src: this.activeData.audio,
                    id: this.activeData.index,
                    mode: 'sound',
                })
                setTimeout(() => {
                    this.isPlayingAudio = false
                }, 3000)
            },

            getChoosePosition(e, type) {
                let positionX, positionY
                if (type === 'touch') {
                    positionX = e.touches[0].pageX
                    positionY = e.touches[0].pageY
                } else {
                    if (type === 'mouse') {
                        positionX = e.clientX
                        positionY = e.clientY
                    }
                }
                return {
                    positionX,
                    positionY
                }
            },

            onColumnChooseStart(e, type) {
                let choosePosition = this.getChoosePosition(e, type)
                let dom = document.elementFromPoint(choosePosition.positionX, choosePosition.positionY)
                let currentPressIndex = Number(dom.getAttribute('columnIndex'))

                this.sendSignal('onColumnChooseStart', {currentPressIndex})
                this.onColumnChooseStartAction(currentPressIndex)
            },

            onColumnChooseStartAction(currentPressIndex) {
                this.isChooseDraging = true

                this.stashIndexList.push(currentPressIndex)
                this.lastPressIndex = currentPressIndex

                this.clearRemindTimeout()
            },

            updateActiveIndex(chooseObjIndex) {
                // 如果已经做完了所有题目
                if (this.unDoneOptionData.length === 0) {
                    this.sendSignal('status')
                    return
                }

                if (chooseObjIndex === this.currentIndex) {
                    let currentIndex
                    // 如果正在做最后一个
                    if (this.currentIndex >= this.optionData.length - 1) {
                        currentIndex = this.unDoneOptionData[0].index
                    }
                    // 如果在做中间的
                    else {
                        let nextOption = this.unDoneOptionData.find(item => {
                            return item.index > this.currentIndex
                        })
                        if (nextOption) {
                            currentIndex = nextOption.index
                        } else {
                            currentIndex = this.unDoneOptionData[0].index
                        }
                    }
                    this.updateCurrentIndexAction(currentIndex)
                }

                this.sendSignal('status')
            },

            isRightChooseResult(text){
                let hasChooseResult = this.optionData.find((item) => {
                    return item.text === text && !item.isFinished
                })
                if (hasChooseResult) {
                    return {
                        isRightResult: hasChooseResult,
                        index: hasChooseResult.index,
                    }
                } else {
                    return {
                        isRightResult: false,
                        index: '-1',
                    }
                }

            },

            onColumnChooseEnd(e) {
                if (!this.isChooseDraging) {
                    return
                }

                this.sendSignal('onColumnChooseEnd', {})
                this.onColumnChooseEndAction()
            },
            onColumnChooseEndAction() {
                this.setRemindTimeout()

                if (this.isChooseDraging) {
                    this.isChooseDraging = false
                }

                // 这个时候判断是否对错
                let chooseResult = ''
                this.stashIndexList.forEach((item) => {
                    chooseResult += this.wordList[item]
                })

                let chooseResultObj = this.isRightChooseResult(chooseResult)
                // 答对了
                if (chooseResultObj.isRightResult) {
                    this.testOkList.push(this.stashIndexList)

                    let startColumn = this.$refs.columnMap[this.stashIndexList[0]]
                    let endColumn = this.$refs.columnMap[this.stashIndexList[this.stashIndexList.length - 1]]
                    this.columnStyleList[this.isFinishedNumber].top = startColumn.offsetTop + 'px'
                    this.columnStyleList[this.isFinishedNumber].left = startColumn.offsetLeft + 'px'
                    this.columnStyleList[this.isFinishedNumber].width = endColumn.offsetLeft + endColumn.offsetWidth - startColumn.offsetLeft + 'px'
                    this.columnStyleList[this.isFinishedNumber].height = endColumn.offsetTop + endColumn.offsetHeight - startColumn.offsetTop + 'px'

                    let newObj = this.optionData[chooseResultObj.index]
                    newObj.isFinished = true
                    this.optionData.splice(chooseResultObj.index, 1, newObj)

                    this.$nextTick(() => {
                        // 做完一道题之后更新当前的index
                        this.updateActiveIndex(chooseResultObj.index)
                    })

                    this.triggerLog({
                        eleList: [{
                            id: 'drag',
                            eleType: 'option',
                            subType: 'text',
                            content: chooseResult,
                        }],
                        action: true,
                        result: 1,
                    })

                    this.stashIndexList = []

                } else {
                    this.triggerLog({
                        eleList: [{
                            id: 'drag',
                            eleType: 'option',
                            subType: 'text',
                            content: chooseResult,
                        }],
                        action: true,
                        result: 0,
                    })
                    // 答错了，释放
                    this.stashIndexList = []
                    this.sendSignal('status')
                }
            },

            cancelStashIndex() {
                this.stashIndexList = []
            },
            onColumnChooseMove(e, type) {
                // 如果不是在拖拽进行中，就什么也不做
                if (!this.isChooseDraging) {
                    return
                }
                let choosePosition = this.getChoosePosition(e, type)
                let dom = document.elementFromPoint(choosePosition.positionX, choosePosition.positionY)

                // 如果移动到了右侧操作区外面，应该停止
                let columnIndex = dom.getAttribute('columnIndex')
                if (this.isNull(columnIndex)) {
                    this.onColumnChooseEnd(e, type)
                    return
                }
                // 在间隙中move,不处理
                if (columnIndex === 'columnIndex') {
                    return
                }
                let currentPressIndex = Number(columnIndex)
                // 还在同一个方格里面，什么也不做
                if (this.lastPressIndex === currentPressIndex) {
                    return
                }

                this.sendSignal('onColumnChooseMove', {currentPressIndex})
                this.onColumnChooseMoveAction(currentPressIndex)
            },

            onColumnChooseMoveAction(currentPressIndex) {
                // console.log('lixin 拖拽中', currentPressIndex, JSON.stringify(this.stashIndexList))

                if (this.stashIndexList.length === 0) {
                    this.stashIndexList.push(currentPressIndex)
                }
                // 如果已经选中了一个的话就只能向右或者向下移动
                else if (this.stashIndexList.length === 1) {
                    // 向右滑动或者向下移动
                    if (currentPressIndex === this.lastPressIndex + 1 || currentPressIndex === this.lastPressIndex + this.matrixCount.columnNumber) {
                        this.stashIndexList.push(currentPressIndex)
                    }
                    // 直接断开，不继续连接
                    else {
                        this.cancelStashIndex()
                        this.onColumnChooseEnd()
                    }
                }
                // 已经选中多个，就要判断当前是在向哪个方向移动
                else {
                    // 1.先判断现在在向右还是在向下
                    let beforeLastIndex = this.stashIndexList.slice(this.stashIndexList.length - 2, this.stashIndexList.length - 1)
                    if (this.lastPressIndex - beforeLastIndex === 1) {
                        // 此时正在水平移动
                        if (currentPressIndex - this.lastPressIndex === 1) {
                            this.stashIndexList.push(currentPressIndex)
                        } else if (currentPressIndex - this.lastPressIndex === -1) {
                            this.stashIndexList.pop()
                        } else {
                            // 直接断开
                            this.cancelStashIndex()
                        }

                    } else if (this.lastPressIndex - beforeLastIndex === this.matrixCount.columnNumber) {
                        // 此时正在垂直移动
                        if (currentPressIndex - this.lastPressIndex === this.matrixCount.columnNumber) {
                            this.stashIndexList.push(currentPressIndex)
                        } else if (currentPressIndex - this.lastPressIndex === -this.matrixCount.columnNumber) {
                            this.stashIndexList.pop()
                        } else {
                            // 直接断开
                            this.cancelStashIndex()
                        }
                    }
                }
                this.lastPressIndex = currentPressIndex
            },

            // 首字母提醒timeout
            setRemindTimeout() {
                this.clearRemindTimeout()
                this.remindTimeout = setTimeout(() => {
                    this.twinkleLetterIndex = this.activeData.columnIndexList[0]
                }, 7000)
            },

            // 清除首字母提醒timeout
            clearRemindTimeout() {
                this.remindTimeout && clearTimeout(this.remindTimeout)
                this.twinkleLetterIndex = -1
            },

            // 点击了start按钮
            startCountDown() {
                this.sendSignal('startCountDown', {})

                this.canControlAnswerArea = true
                this.setRemindTimeout()
            },

            startCountDownAction() {
                this.canControlAnswerArea = true
                this.setRemindTimeout()

                this.$refs.clock.startCountDownAction()
            },

            // 点击了pause按钮
            pauseCountDown() {
                this.sendSignal('pauseCountDown', {})

                this.canControlAnswerArea = false
                this.clearRemindTimeout()
            },

            pauseCountDownAction() {
                this.canControlAnswerArea = false
                this.clearRemindTimeout()

                this.$refs.clock.pauseCountDownAction()
            },

            // 倒计时数字更新了
            updateCountNumber(countNumber) {
                this.countNumber = countNumber
                // 这个时候应该显示没有做对的答案了
                if (this.countNumber === 0) {
                    this.triggerLog({
                        eleList: [{
                            id: 'time',
                            eleType: 'question',
                            subType: 'text',
                            content: 'time over',
                        }],
                        action: true,
                        result: 1,
                    })

                    // 倒计时为0的时候如果还在按压屏幕，就应该清除选择的字母
                    this.stashIndexList = []
                    this.onColumnChooseEnd()

                    let reallyRightNumber = this.isFinishedNumber

                    this.canControlAnswerArea = false

                    this.optionData.forEach((item, index) => {
                        if (!item.isFinished) {
                            let startColumn = this.$refs.columnMap[item.columnIndexList[0]]
                            let endColumn = this.$refs.columnMap[item.columnIndexList[item.columnIndexList.length - 1]]
                            this.columnStyleList[reallyRightNumber].top = startColumn.offsetTop + 'px'
                            this.columnStyleList[reallyRightNumber].left = startColumn.offsetLeft + 'px'
                            this.columnStyleList[reallyRightNumber].width = endColumn.offsetLeft + endColumn.offsetWidth - startColumn.offsetLeft + 'px'
                            this.columnStyleList[reallyRightNumber].height = endColumn.offsetTop + endColumn.offsetHeight - startColumn.offsetTop + 'px'

                            this.testOkList.push(item.columnIndexList)

                            reallyRightNumber++
                        }
                    })

                    this.sendSignal('status')
                }
                this.sendSignal('countNumber', {countNumber})
            },

            // 题目全部都做完了，应该停止倒计时
            hadFinishedTest() {
                this.isTestFinished = true
                this.pauseCountDownAction()
            },

            restoreCardRotary() {
                this.cardRotaryList = [].concat(['', this.optionData[this.currentIndex].image, ''])
                this.$refs.cardRotary.style.top = '-189px'
            },

            // 模版被重置了
            restore() {
                this.currentIndex = 0
                this.stashIndexList = []
                this.testOkList = []
                this.isChooseDraging = false
                this.lastPressIndex = -1

                this.isFinishedNumber = 0

                this.columnStyleList = []
                this.optionData.forEach((item) => {
                    item.isFinished = false
                    this.columnStyleList.push({
                        width: '',
                        height: '',
                        top: '',
                        left: '',
                    })
                })

                this.restoreCardRotary()

                this.canControlAnswerArea = false

                // 重置音频播放状态
                this.pauseAudio()
                this.timeOut && clearTimeout(this.timeOut)
                this.canPlayAudio = true

                // 重置clock组建
                this.$refs.clock.restore()
                this.countNumber = this.timerNumber

                // 清除提醒的timeout
                this.clearRemindTimeout()

                this.isTestFinished = false
            },
            sendSignal(name, val = null) {
                // if (name !== 'countNumber') {
                //     console.log('lixin 发送实时信令', name, val)
                // }
                if (name && val) {
                    this.$emit('event', {
                        type: 'sendSignal',
                        data: {
                            name,
                            val: {
                                key: signalHandle.wrap(val)
                            }
                        }
                    })
                } else if (name === 'status') {
                    let statusObj = {
                        // 当前正在进行第几道题
                        currentIndex: this.currentIndex,
                        // 当前存储的选中的数组
                        stashIndexList: this.stashIndexList,
                        // 所有已经选对的字母集合
                        testOkList: this.testOkList,
                        // 上一个被选中的方格
                        lastPressIndex: this.lastPressIndex,
                        // 所有选项数据集合
                        optionData: this.optionData,
                        columnStyleList: this.columnStyleList,
                    }
                    // console.log('lixin 发送状态信令', statusObj)
                    this.$emit('event', {
                        type: 'sendSignal',
                        data: {
                            name: 'status',
                            val: {
                                key: signalHandle.wrap(statusObj)
                            }
                        }
                    })
                }
            },
            postMessage(type, data) {
                if (type === 'history') {
                    let {historyObj} = data
                    for (let name in historyObj) {
                        let dataObj = signalHandle.parse(historyObj[name].key)
                        if (name === 'status') {
                            console.log('lixin IC011-signal 接收到历史信令', name, dataObj)
                            this.currentIndex = dataObj.currentIndex
                            this.stashIndexList = dataObj.stashIndexList
                            this.testOkList = dataObj.testOkList
                            this.lastPressIndex = dataObj.lastPressIndex
                            this.optionData = dataObj.optionData
                            this.columnStyleList = dataObj.columnStyleList

                            this.restoreCardRotary()
                        }
                        if (name === 'countNumber') {
                            // console.log('lixin 接收到历史信令', name, dataObj)
                            this.$refs.clock.updateHistoryCountNumber(dataObj.countNumber)
                        }
                    }
                } else if (type === 'live') {
                    let {name ,val} = data
                    val = signalHandle.parse(val.key)
                    // if (name !== 'countNumber') {
                    //     console.log('lixin 接收实时信令********', name, val)
                    // }
                    if (name === 'updateCurrentIndex') {
                        this.updateCurrentIndexAction(val.index)
                    }
                    if (name === 'playTestAudio') {
                        this.playTestAudioAction()
                    }
                    if (name === 'onColumnChooseStart') {
                        this.onColumnChooseStartAction(val.currentPressIndex)
                    }
                    if (name === 'onColumnChooseMove') {
                        this.onColumnChooseMoveAction(val.currentPressIndex)
                    }
                    if (name === 'onColumnChooseEnd') {
                        this.onColumnChooseEndAction()
                    }
                    if (name === 'status') {
                        this.currentIndex = val.currentIndex
                        this.stashIndexList = val.stashIndexList
                        this.testOkList = val.testOkList
                        this.lastPressIndex = val.lastPressIndex
                        this.optionData = val.optionData
                        this.columnStyleList = val.columnStyleList
                    }

                    if (name === 'startCountDown') {
                        this.startCountDownAction()
                    }
                    if (name === 'pauseCountDown') {
                        this.pauseCountDownAction()
                    }
                    if (name === 'countNumber') {
                        this.$refs.clock.updateCurrentCountNumber(val.countNumber)
                    }
                }
            },
        },
        mounted() {
            this.audioPlayer = new Audio()

            this.$emit('event', {
                type: 'ready',
                data: {
                    audioList: [],
                    vm: this,
                }
            })
        },
        beforeDestroy() {
            this.pauseCountDownAction()
            this.clearRemindTimeout()
        },
    }
</script>

<style lang='scss' src="./style/main-IC.scss" scoped></style>
