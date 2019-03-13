import numpy as np




def veloc_update(pcurr, vcurr, pbest, pgbest, params):
    rpg = np.random.uniform(0, 1, 2)
    vcurr = params[0] * vcurr + params[1] * rpg[0] * (pbest - pcurr) + params[2] * rpg[1] * (pgbest - pcurr)
    return vcurr


def posit_update(pcurr, vcurr, bounds):
    newp = pcurr + vcurr
    for i in range(len(newp)):
        if newp[i] > bounds[0] and newp[i] < bounds[1]:
            pcurr[i] = newp[i]
    return pcurr



def point_update(pcurr, vcurr, pbest, fbest, pgbest, params, bounds, f):
    n = len(pcurr)
    for d in range(n):
        vcurr[d] = veloc_update(pcurr[d], vcurr[d], pbest[d], pgbest[d], params)
    newp = pcurr + vcurr
    for i in range(len(newp)):
        if newp[i] > bounds[i][0] and newp[i] < bounds[i][1]:
            pcurr[i] = newp[i] + 0
    fcurr = f(pcurr)
    if fcurr < fbest:
        fbest = fcurr + 0
        pbest = pcurr + 0
    return pcurr.tolist(), vcurr.tolist(), pbest.tolist(), fbest



def dist(v1, v2):
    distt = np.sum(np.sqrt(np.sum(np.square(v1 - v2), axis=1)))
    return distt
