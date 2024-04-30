#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

int main(int argc, char **argv)
{

	int x_coord = atoi(argv[1]);
	int y_coord = atoi(argv[2]);
	
	//Open Display
	Display *my_display = XOpenDisplay(NULL);
	
	//Get size
	int xmax = XDisplayWidth(my_display,XDefaultScreen(my_display));
	int ymax = XDisplayHeight(my_display,XDefaultScreen(my_display));
	
	//Info
	fprintf(stderr,"Info --> Width: %d / Height: %d\n",xmax,ymax);
	
	//Verify Bounds
	if (x_coord>xmax || y_coord>ymax)
	{
		fprintf(stderr,"Error: Pixel out of bounds\n");
		XCloseDisplay(my_display);
		exit(1);
	}
	
	//Grab Screenshot
	XImage *screenshot = XGetImage( my_display, XRootWindow(my_display, XDefaultScreen(my_display)), x_coord, y_coord, 1, 1, AllPlanes, XYPixmap);

	fprintf(stdout,"%x\n",XGetPixel(screenshot, 0, 0));

	//Close Display
	XCloseDisplay(my_display);

}
