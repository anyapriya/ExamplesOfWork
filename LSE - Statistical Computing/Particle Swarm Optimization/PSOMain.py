import numpy as np
import multiprocessing as mp
from itertools import repeat
import heapq


import PSOTestFuncs as tf
from PSOInit import pso_init
from PSOUpdate import veloc_update
from PSOUpdate import point_update
from PSOUpdate import dist





def pso_algo(f, s, bounds, params, maxrounds, p=0.9,optimum_dis=0.01):
    n = len(bounds)
    pcurr, vcurr, pbest, fbest, pgbest, fgbest = pso_init(f, s, bounds)
    nrounds = 1
    while (nrounds <= maxrounds):
        for i in range(s):
            for d in range(n):
                vcurr[i][d] = veloc_update(pcurr[i][d], vcurr[i][d], pbest[i][d], pgbest[d], params)
            pcurr[i] = pcurr[i] + vcurr[i]
            fcurr = f(pcurr[i])
            if fcurr < fbest[i]:
                fbest[i] = fcurr + 0
                pbest[i] = pcurr[i] + 0
                if fcurr < fgbest:
                    fgbest = fcurr + 0
                    pgbest = pcurr[i] + 0
        nrounds += 1
        pcurr_best = pcurr[fbest > min(heapq.nlargest(int(fbest.size*p), fbest))]
        if dist(pcurr_best, pgbest) <= optimum_dis:
            break
    return pgbest, fgbest







def pso_algo_par(f, s, bounds, params, maxrounds, p=0.9,optimum_dis=0.01):
    n = len(bounds)
    pcurr, vcurr, pbest, fbest, pgbest, fgbest = pso_init(f, s, bounds)
    nrounds = 1
    while(nrounds <= maxrounds):

        inputs = zip(pcurr, vcurr, pbest, fbest, repeat(pgbest), repeat(params), repeat(bounds), repeat(f))

        results_0 = pool.starmap(point_update, inputs)
        results = list(map(list, zip(*results_0)))

        pcurr = np.array(list(results)[0])
        vcurr = np.array(list(results)[1])
        pbest = np.array(list(results)[2])
        fbest = np.array(list(results)[3])

        if min(fbest) < fgbest:
            fgbest = min(fbest) + 0
            pgbest = np.copy(pbest[fbest == fgbest], order="k")[0]

        nrounds += 1
        pcurr_best = pcurr[fbest > min(heapq.nlargest(int(fbest.size*p), fbest))]
        if dist(pcurr_best, pgbest) <= optimum_dis:
            break
    return pgbest, fgbest










if __name__ == '__main__':

    s = 1000
    params = [0.715, 1.7, 1.7]
    maxrounds = 1000

    cores = mp.cpu_count()
    pool = mp.Pool(processes=cores)

    # f(0) = 0
    np.random.seed(1234)
    f = tf.xsq
    bounds = [[-200, 200]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(1,3) = 0
    np.random.seed(1234)
    f = tf.booth
    bounds = [[-10, 10], [-10, 10]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(3,0.5) = 0
    np.random.seed(1234)
    f = tf.beale
    bounds = [[-4.5, 4.5], [-4.5, 4.5]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(0,0) = 0
    np.random.seed(1234)
    f = tf.threehumpcamel
    bounds = [[-5, 5], [-5, 5]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(0,-1) = 3
    np.random.seed(1234)
    f = tf.goldsteinprice
    bounds = [[-2, 2], [-2, 2]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(1,1) = 0
    np.random.seed(1234)
    f = tf.levi_n13
    bounds = [[-10, 10], [-10, 10]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(0,...,0) = 0
    np.random.seed(1234)
    f = tf.sphere
    # Search area should be infinity, also can change # of variables
    bounds = [[-100, 100], [-100, 100], [-100, 100], [-100, 100]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(1,...,1) = 0
    np.random.seed(1234)
    f = tf.rosenbrock
    # Search area should be infinity, also can change # of variables
    bounds = [[-100, 100], [-100, 100], [-100, 100], [-100, 100]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # -39.16617n < f(-2.903534,...,-2.903534) < -39.16616n
    np.random.seed(1234)
    f = tf.Styblinski_Tang
    # Can change # of variables
    bounds = [[-5, 5], [-5, 5], [-5, 5], [-5, 5], [-5, 5], [-5, 5]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(0,0) = 0
    np.random.seed(1234)
    f = tf.ackley
    bounds = [[-5, 5], [-5, 5]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(0,0) = 0
    np.random.seed(1234)
    f = tf.schaffer_n2
    bounds = [[-100, 100], [-100, 100]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(512,404.2319) = -959.6407
    np.random.seed(12345)
    f = tf.eggholder
    bounds = [[-512, 512], [-512, 512]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(-0.54719, -1.54719) = -1.9133
    np.random.seed(1234)
    f = tf.mccormick
    bounds = [[-1.5, 4], [-3, 4]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))



############################# These don't converge to right values #########################################

    # f(0,1.25313) = 0.292579
    np.random.seed(1234)
    f = tf.schaffer_n4
    bounds = [[-100, 100], [-100, 100]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(0,...,0) = 0
    np.random.seed(12345)
    f = tf.rastrigin
    # Can change # of variables
    bounds = [[-5.12, 5.12], [-5.12, 5.12], [-5.12, 5.12], [-5.12, 5.12], [-5.12, 5.12], [-5.12, 5.12], [-5.12, 5.12], [-5.12, 5.12]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(pi,pi) = -1
    np.random.seed(1234)
    f = tf.easom
    bounds = [[-100, 100], [-100, 100]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(-10,1) = 0
    np.random.seed(1234)
    f = tf.bukin_n6
    bounds = [[-15, -5], [-3, 3]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))


    # f(0,0) = 0
    np.random.seed(1234)
    f = tf.matyas
    bounds = [[-10.00, 10.00], [-10.00, 9.00]]
    pmin, fmin = pso_algo(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))
    pmin, fmin = pso_algo_par(f, s, bounds, params, maxrounds)
    print("Min of: " + str(fmin) + " at: " + str(pmin))



    pool.close()
