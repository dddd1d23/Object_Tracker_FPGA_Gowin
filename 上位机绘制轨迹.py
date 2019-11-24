import serial
import cv2
import numpy as np

x = []
y = []


def move(x, y):
    global frame, current_measurement, measurements, last_measurement, current_prediction, last_prediction, sign_m
    last_prediction = current_prediction  # 把当前预测存储为上一次预测
    last_measurement = current_measurement  # 把当前测量存储为上一次测量
    current_measurement = np.array([[np.float32(x)], [np.float32(y)]])  # 当前测量
    kalman.correct(current_measurement)  # 用当前测量来校正卡尔曼滤波器
    current_prediction = kalman.predict()  # 计算卡尔曼预测值，作为当前预测

    lmx, lmy = last_measurement[0], last_measurement[1]  # 上一次测量坐标
    cmx, cmy = current_measurement[0], current_measurement[1]  # 当前测量坐标
    lpx, lpy = last_prediction[0], last_prediction[1]  # 上一次预测坐标
    cpx, cpy = current_prediction[0], current_prediction[1]  # 当前预测坐标
    # 绘制从上一次测量到当前测量以及从上一次预测到当前预测
    # 的两条线
    cv2.line(frame, (lmx, lmy), (cmx, cmy), (255, 0, 0))  # 蓝色线为测量值
    cv2.line(frame, (lpx, lpy), (cpx, cpy), (255, 0, 255))  # 粉色线为预测值


ser = serial.Serial(timeout=0.00001)
ser.port = 'COM10'
ser.baudrate = 115200
ser.open()
frame = np.ones((600, 800, 3), np.uint8)
frame = frame * 255
# 初始化测量坐标和运动预测的数组
last_measurement = current_measurement = np.array((2, 1), np.float32)
last_prediction = current_prediction = np.zeros((2, 1), np.float32)

# 窗口初始化
cv2.namedWindow("kalman_tracker")

kalman = cv2.KalmanFilter(
    4, 2)  # 4：状态数，包括（x，y，dx，dy）坐标及速度（每次移动的距离）；2：观测量，能看到的是坐标值
kalman.measurementMatrix = np.array([[1, 0, 0, 0], [0, 1, 0, 0]],
                                    np.float32)  # 系统测量矩阵
kalman.transitionMatrix = np.array(
    [[1, 0, 1, 0], [0, 1, 0, 1], [0, 0, 1, 0], [0, 0, 0, 1]],
    np.float32)  # 状态转移矩阵
kalman.processNoiseCov = np.array(
    [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
    np.float32) * 0.03  # 系统过程噪声协方差
while 1:
    x_1 = x_2 = y_1 = y_2 = None
    input_bytes = ser.read(100)
    if len(input_bytes) != 0:
        sign = input_bytes.find(b'\xff\xfe\xfd')
        # print(input_bytes[sign+4:sign+6])
        if input_bytes[sign + 8] == input_bytes[sign + 4] ^ input_bytes[
                sign + 5] ^ input_bytes[sign + 6] ^ input_bytes[sign + 7]:
            print(
                int.from_bytes(input_bytes[sign + 4:sign + 6],
                               byteorder='big',
                               signed=False))
            print(
                int.from_bytes(input_bytes[sign + 6:sign + 8],
                               byteorder='big',
                               signed=False))
            x.append(
                int.from_bytes(input_bytes[sign + 4:sign + 6],
                               byteorder='big',
                               signed=False))
            y.append(
                int.from_bytes(input_bytes[sign + 6:sign + 8],
                               byteorder='big',
                               signed=False))
            if len(x) >= 5:
                del (x[0], y[0])
                move(800 - int((x[0] + x[1] + x[2]) / 3),
                     int((y[0] + y[1] + y[2]) / 3))
        '''if x_1 ^ x_2 ^ y_1 ^ y_2 != cherk:
                continue
            else:
                x_tmp = int.from_bytes(x_1 + x_2,
                                       byteorder='big',
                                       signed=False)
                y_tmp = int.from_bytes(y_1 + y_2,
                                       byteorder='big',
                                       signed=False)
                move(x_tmp, y_tmp)      
        else:
            continue'''
    cv2.imshow("kalman_tracker", frame)
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):  # 按下q退出
        break
    elif key == ord('c'):  # 按下c清屏
        del (frame)
        frame = np.ones((600, 800, 3), np.uint8) * 255
