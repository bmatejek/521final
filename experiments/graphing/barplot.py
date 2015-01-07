import csv
import matplotlib.pyplot as plt
import numpy as np
import sys

reader = csv.reader(open(sys.argv[1]), delimiter=' ')
header = reader.next()
data = []
for row in reader:
    vals = [float(x) for x in row]
    m = min(vals)
    data.append([x / m for x in vals])


ind = np.arange(len(data))
width = 0.7/len(data[0])


fig, ax = plt.subplots()
rects = []
for i in range(len(data[0])):
    rects.append(ax.bar(ind + i * width, [float(x[i]) for x in data], width, color="bgrcmykw"[i]))

# add some text for labels, title and axes ticks
ax.set_ylabel('Cost')
ax.set_title('Costs relative to best in each round')
ax.set_xticks(ind+width)
ax.set_xticklabels( [i for i in range(len(data))] )

ax.legend( tuple(rects), tuple(header) )

def autolabel(rects):
    # attach some text labels
    for rect in rects:
        height = rect.get_height()
        ax.text(rect.get_x()+rect.get_width()/2., 1.05*height, '%d'%int(height),
                ha='center', va='bottom')

#autolabel(rects1)
#autolabel(rects2)

plt.show()
