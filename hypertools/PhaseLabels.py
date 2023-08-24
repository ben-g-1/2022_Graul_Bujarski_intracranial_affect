# phase_dict = {Dictionary} the key is the phase number or label and the value is the number rows
def phaseclass(phase_dict):
    # Phases of stimuli list setup:
    phase_labels = []
    for phase_num, phase_count in phase_dict.items():
        for p in range(phase_count):
            phase_labels.append(phase_num)
    print(phase_labels)
    return phase_labels
