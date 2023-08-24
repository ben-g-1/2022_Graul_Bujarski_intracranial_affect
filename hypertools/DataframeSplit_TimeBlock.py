# df = {DataFrame} Dataframe to split into timeblocks

# idx_list = {List of list} A list of index positions (the start and end) of timeblocks
#   ex: [[idx1a, idx1b], [], []. []]

# num_blocks = {Int} number of timeblocks to create
#   ex: 1, 2, 3, 4 seconds of stimuli onset
def group_tblock(df, num_blocks, idx_list):
    timeblocks = []
    for timeblock in range(1, num_blocks+1):
        timeblocks[timeblock] = df.iloc[idx_list[timeblock][0]:idx_list[timeblock][1], :]
        timeblocks[timeblock] = timeblocks[timeblock].reset_index()
        timeblocks[timeblock].drop(columns=['index'], inplace=True)

    return timeblocks
