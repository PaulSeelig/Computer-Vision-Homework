# Python program to explain cv2.rotate() method

# importing cv2
import cv2

# Done in large following this: https://www.geeksforgeeks.org/python/getting-started-with-python-opencv/
def main():
    cap = cv2.VideoCapture(0) # GStreamer was unavailable

    # Create a window FIRST
    cv2.namedWindow('edged_RGB')

    # Create trackbars ONCE (outside the loop) 
    cv2.createTrackbar('Upper', 'edged_RGB', 150, 300, lambda x: None) # done using ChatGBT and advice from: "Live-Farbsegmentierung im Kamerabild (Deadline 21.4.)"
    cv2.createTrackbar('Lower', 'edged_RGB', 0, 150, lambda x: None)

    # loop runs if capturing has been initialized.
    while 1:

        # reads frames from a camera
        ret, img = cap.read()

        # convert to gray scale of each frames
        gray_RGB = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)

        # Blur
        Gaussian = cv2.GaussianBlur(img, (5, 5), 0)

        # Read trackbar values
        upper = cv2.getTrackbarPos('Upper', 'edged_RGB')
        lower = cv2.getTrackbarPos('Lower', 'edged_RGB')
        
        edged_RGB = cv2.Canny(img, lower, upper) # after experimenting min 100 and max 150 results in a reasonable stream quality

        # Display the images
        cv2.imshow('img',img)
        cv2.imshow('gray_RGB',gray_RGB)
        cv2.imshow('Gaussian Blurring', Gaussian)
        cv2.imshow('edged_RGB', edged_RGB)


        # Wait for q key to stop
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    # Close the window
    cap.release()

    # De-allocate any associated memory usage
    cv2.destroyAllWindows()



if __name__ == "__main__":
    main()