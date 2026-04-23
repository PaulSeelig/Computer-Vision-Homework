# Python program to explain cv2.rotate() method

# importing cv2
import cv2
import numpy 
# Done in large following this: https://docs.opencv.org/4.x/df/d9d/tutorial_py_colorspaces.html
def main():
    cap = cv2.VideoCapture(0) # GStreamer was unavailable

    '''
    Belichtungszeit (CAP_PROP_EXPOSURE)
    Gain/ISO (CAP_PROP_GAIN)
    Helligkeit (CAP_PROP_BRIGHTNESS)

    '''

    exposure = cap.get(cv2.CAP_PROP_EXPOSURE)
    # Create windows
    cv2.namedWindow('Kernel Range')

    cv2.createTrackbar('Range', 'Kernel Range', 5, 50, lambda x: None)
    # loop runs if capturing has been initialized.
    while 1:

        # reads frames from a camera
        ret, img = cap.read()
        
        key = cv2.waitKey(1) & 0xFF
        # Wait for q key to stop
        if key == ord("q"):
            break

        if  key == ord("+"):
            exposure += 1
            cap.set(cv2.CAP_PROP_EXPOSURE, exposure)
        if key == ord("-"):
            exposure -= 1
            cap.set(cv2.CAP_PROP_EXPOSURE, exposure)

        print("Camera Exposure: {}".format(exposure))
        print("Camera ISO: {}".format(cap.get(cv2.CAP_PROP_GAIN)))
        print("Camera Brightness: {}".format(cap.get(cv2.CAP_PROP_BRIGHTNESS)))

        kernel_size = cv2.getTrackbarPos('Range', 'Kernel Range') 

        kernel_h = numpy.zeros((kernel_size, kernel_size))

        kernel_h[int((kernel_size -1)/2), :] = numpy.ones(kernel_size)

        kernel_h /= kernel_size

        motion_blur_horizontal = cv2.filter2D(img, -1, kernel_h)


        cv2.imshow('frame',img)
        cv2.imshow('Motion-Blur', motion_blur_horizontal)

        

    # Close the window
    cap.release()

    # De-allocate any associated memory usage
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()