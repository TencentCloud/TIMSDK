/**
 * @module interface
 */
interface V2TimValueCallback<T> {
    code: number;
    desc: String;
    data?: T;
}

export default V2TimValueCallback;
