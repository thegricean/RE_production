import os, csv


datadir = "."

csv_messagenames = [o for o in os.listdir("./message/") if (o.endswith('csv') & o.startswith('2016-10'))]

csv_trialnames =  [o for o in os.listdir("./clickedObj/") if (o.endswith('csv') & o.startswith('2016-10'))]


# helper function to get messages associated with a particular trial
def getMessages(trial, messages):
	speakermessages = []
	listenermessages = []
	times = []
	
	for m in messages:
		if m['roundNum'] == str(trial):
			if m['sender'] == 'speaker':
				speakermessages.append(m['contents'])
			else:
				listenermessages.append(m['contents'])
			times.append(m['time'])
			
	mess = {'nummessages': len(speakermessages) + len(listenermessages),
			'numsmessages': len(speakermessages),
			'numlmessages': len(listenermessages),			 
			'listenermessages': listenermessages,
			'speakermessages': speakermessages,
			'times': times}		
			
	return mess
	
# first make sure that for every trial file there's a message file
for t in csv_trialnames:
	shared = False
	gameid = t[0:20]
	for m in csv_messagenames:	
		if m.startswith(gameid):
			shared = True

	if shared == False:
		print "corresponding message file not found: " + gameid
		csv_trialnames.pop(csv_trialnames.index(t))

print csv_messagenames
print csv_trialnames

print "Number of message files: " + str(len(csv_messagenames))
print "Number of trial files: " + str(len(csv_trialnames))



finalmessagelines = []
finaltriallines = []

# the meaty bit
for k,m in enumerate(csv_messagenames):
	#print m
	messagelines = []
	triallines = []

	messagereader = csv.DictReader(open(datadir+"/message/"+m, 'rb'),delimiter=",",quotechar='\"')
	messagelines.extend(list(messagereader))


	trialreader = csv.DictReader(open(datadir+"/clickedObj/"+m, 'rb'),delimiter=",",quotechar='\"')
	triallines.extend(list(trialreader))
	headers = trialreader.fieldnames		

	for trial in range(1,len(triallines)+1):
		mess = getMessages(trial,messagelines)
		i = trial - 1
		triallines[i]['numMessages'] = mess['nummessages']
		triallines[i]['numSMessages'] = mess['numsmessages']	
		triallines[i]['numLMessages'] = mess['numlmessages']		
		triallines[i]['speakerMessages'] = "___".join(mess['speakermessages'])
		triallines[i]['listenerMessages'] = "___".join(mess['listenermessages'])
		triallines[i]['messageTimeStamps'] = "___".join(mess['times'])
		print i
		print k
		print mess['speakermessages']
		try:
			triallines[i][' refExp']	= mess['speakermessages'][0]
		except IndexError:
			triallines[i][' refExp'] = "NA"	
		print triallines[i]['nameClickedObj']
		try:			
			typ,color = triallines[i]['nameClickedObj'].split("_")
		except ValueError:
			dist,typ,color = triallines[i]['nameClickedObj'].split("_")
		triallines[i]['clickedColor'] = color
		triallines[i]['clickedType'] = typ
		colormentioned = False	
		typementioned = False	

		try:
			refexp = [m.lower() for m in mess['speakermessages'][0].split()]
			if color in refexp:
				colormentioned = True
			if typ in refexp:
				typementioned = True
		except IndexError:
			print "no message on this trial"
		triallines[i]['colorMentioned'] = colormentioned	
		triallines[i]['typeMentioned'] = typementioned	

#	finalmessagelines = finalmessagelines + messagelines
	finaltriallines = finaltriallines + triallines		
	

headers.append('numMessages')
headers.append('numSMessages')	
headers.append('numLMessages')
headers.append('speakerMessages')
headers.append('listenerMessages')
headers.append('messageTimeStamps')
headers.append(' refExp')
headers.append('colorMentioned')
headers.append('typeMentioned')
headers.append('clickedType')
headers.append('clickedColor')



#print headers

print triallines[0].keys()


w = csv.DictWriter(open("rawdata_exp2.csv", "wb"),fieldnames=headers,restval="NA",delimiter="\t")
w.writeheader()
w.writerows(finaltriallines)
			
