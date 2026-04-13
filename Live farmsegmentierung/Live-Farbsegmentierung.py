# Python program to explain cv2.rotate() method

# importing cv2
import cv2
import numpy 
# Done in large following this: https://docs.opencv.org/4.x/df/d9d/tutorial_py_colorspaces.html
def main():
    cap = cv2.VideoCapture(0) # GStreamer was unavailable

    # Create windows
    cv2.namedWindow('HSV')
    cv2.namedWindow('Regler')

    # Create trackbars ONCE (outside the loop) 
    cv2.createTrackbar('Hue_lower', 'Regler', 0, 179, lambda x: None) # Taken from my previously submitted python file
    cv2.createTrackbar('Saturation_lower', 'Regler', 0, 255, lambda x: None)
    cv2.createTrackbar('Value_lower', 'Regler', 0, 255, lambda x: None)

    cv2.createTrackbar('Hue_upper', 'Regler', 170, 179, lambda x: None) 
    cv2.createTrackbar('Saturation_upper', 'Regler', 255, 255, lambda x: None)
    cv2.createTrackbar('Value_upper', 'Regler', 255, 255, lambda x: None)
    # loop runs if capturing has been initialized.
    while 1:

        # reads frames from a camera
        ret, img = cap.read()

        # convert to hvs
        blur = cv2.GaussianBlur(img, (15, 15), 0) 
        hsv = cv2.cvtColor(blur, cv2.COLOR_RGB2HSV)
        
        Hue_L = cv2.getTrackbarPos('Hue_lower', 'Regler')
        Saturation_L = cv2.getTrackbarPos('Saturation_lower', 'Regler')
        Value_L = cv2.getTrackbarPos('Value_lower', 'Regler')

        Hue_U = cv2.getTrackbarPos('Hue_upper', 'Regler')
        Saturation_U = cv2.getTrackbarPos('Saturation_upper', 'Regler')
        Value_U = cv2.getTrackbarPos('Value_upper', 'Regler')

        # define range of color in HSV
        lower = numpy.array([Hue_L,Saturation_L,Value_L])
        upper = numpy.array([Hue_U,Saturation_U,Value_U])

        # Threshold the HSV image
        mask = cv2.inRange(hsv, lower, upper)

        # Bitwise-AND mask and original image
        res = cv2.bitwise_and(img,img, mask= mask)
    
        cv2.imshow('frame',img)
        cv2.imshow('mask',mask)
        cv2.imshow('HSV',res)
    
        # Wait for q key to stop
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    # Close the window
    cap.release()

    # De-allocate any associated memory usage
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()