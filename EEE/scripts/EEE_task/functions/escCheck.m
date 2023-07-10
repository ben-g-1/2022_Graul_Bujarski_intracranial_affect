function escCheck(p, trial)
[keyIsDown,trial,keyCode] = KbCheck;
if keyCode(p.keys.esc)
    Print(['Escape Key pressed during trial ', (trial), '. Exiting now.'])
    ShowCursor
    sca;
end