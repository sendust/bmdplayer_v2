def frames_to_timecode(frames):
    # frame to smpte time code  fot NTSC drop frame
    framerate = 29.97
    fps_int = int(framerate + 0.5)      # round up framerate
    sizeBigCycle = 17982			    # every 10 minute, there is no tc drop
    sizeWeeCycle = 1798			        # every  1 minute, there is tc drop
    numBigCycles = frames // sizeBigCycle
    tailFrames = frames - (numBigCycles * sizeBigCycle)
	
    if (tailFrames < (sizeWeeCycle + 2)):
        numWeeCycles = 1
    else:
        numWeeCycles = (tailFrames - 2) // sizeWeeCycle + 1
	
    numSkips1 = numWeeCycles - 1
    numSkips2 = numBigCycles * 9
    numSkips3 = numSkips1 + numSkips2
    framesSkipped = numSkips3 * 2
    adjustedFrames = frames + framesSkipped
	
    frame = adjustedFrames % fps_int
    seconds = (adjustedFrames // fps_int) % 60
    minutes = (adjustedFrames // (fps_int * 60)) %  60
    hours = adjustedFrames // (fps_int * 3600)
	
    result = "{h:01d}:{m:02d}:{s:02d};{f:02d}"
    return result.format(h = hours, m = minutes, s = seconds, f = frame)
    
    
    
print(frames_to_timecode(100))