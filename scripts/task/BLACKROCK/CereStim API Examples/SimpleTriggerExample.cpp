#include "BStimulator.h"
#include <iostream>
#include <Windows.h>

using namespace std;

int main()
{
	BStimulator cerestim; //declare BStimulator object named cerestim

	std::vector<UINT32> deviceList;
	BResult res = cerestim.scanForDevices(deviceList); //populate device list with SN of connected devices

	for (int i = 0; i < deviceList.size(); i++) {
		cout << deviceList.at(i);
	} // print serial numbers
	
	Sleep(1500); //allow some human readable time

	BResult res = cerestim.setDevice(0); //hardcode the script to connect to the first device

	BResult res = cerestim.connect(BINTERFACE_DEFAULT, 0); //connect to the selected device in setDevice

	BResult res = cerestim.configureStimulusPattern((BConfig)1, BWF_CATHODIC_FIRST, 5, 200, 200, 100, 100, 50, 53);
	// Load a waveform '1' onto the CereStim 
	// Waveform properties: cathodic first, 5 pulses, Phase 1: 200 microamps, 100 uS; Phase 2: 200 microamps, 100 microseconds
	// frequency: 50 Hz, interphase: 53 whatever
	// Note: Loading a waveform onto the CereStim has a latency of about 2 milliseconds; this lateny increases with more waveforms loaded
	//			Latency will be up to 37 ms for a full change of 16 waveforms

	//Load a stimulation program onto the CereStim with one waveform

	res = cerestim.beginningOfSequence();		//	define the beginning of a program
	res = cerestim.beginningOfGroup();			//	define the beginning of a stimulation group (all stimuli in this group will be executed simultaneously)
	res = cerestim.autoStimulus(1, (BConfig)1);	//	stimulate with waveform 1 on electrode 1 (does not stimulate; simply defines this stimulation as part of the group)
	res = cerestim.endOfGroup();				//	define the ending of a stimulation group
	res = cerestim.endOfSequence();				//	define the end of the program

	//	place the cerestim into trigger mode; trigger mode is persistent and CereStim will remain in trigger mode after the script ends until 
	//	it receives cerestim.stopTriggerStimulus or the device is power-cycled.
	res = cerestim.triggerStimulus(BTRIGGER_CHANGE);

	// instead of trigger, could simply play the program using the play command. Refer to the CereStim API documentation to see more information on this and other commands.

	return 0;

	// Would be best to have a cleanup step to stop the trigger and then disconnect the Cerestim using cerestim.disconnect()

}