import math

def p(q, s):
	output = False
	print "*****testing query '%s' against candidate '%s'" % (q, s)
	total = 0
	for i in range(len(q)):
		prob_char = 0
		for j in range(len(s)):
			if q[i:i+1] == s[j:j+1]:
				#print "match!"
				d = math.fabs(i - j)
				prob_char_temp = 1 - (float(d) / len(q))
				if output: print "match for '%s'! prob_char_temp: %f" % (q[i:i+1], prob_char_temp)
				prob_char = max(prob_char, prob_char_temp)
		if output: print "final prob_char for '%s': %f" % (q[i:i+1], prob_char)
		total += prob_char
		#print "prob_char when comparing '%s' in query string to '%s' in candidate string: %f" % (q[i:i+1], s[j:j+1], prob_char)
	prob_total = float(total) / len(q)
	# scale probability by diff in length between q and s over len(s)
	prob_scale = 1 - ((math.fabs(len(s) - len(q))) / len(s))
	print "scale: %f" % prob_scale
	# don't multiply just yet...

	print "without scale: probability that '%s' matches '%s': %f" % (q, s, prob_total)
	# scale kinda sucks...
	print "with scale: probability that '%s' matches '%s': %f" % (q, s, prob_total * prob_scale)

p("sa", "san")
p("s#n", "san")
p("ssn", "san")
p("s#n", "san")
p("san", "san")
p("v;asv;oiashf", "sandsafsdfasdf")
p("sans mateos highs schools", "san mateo high school")
p("san mateo high schoooooooooooooooooool", "san mateo high school")
p("san mateo high school", "balboa high school")
p("h;", "h")