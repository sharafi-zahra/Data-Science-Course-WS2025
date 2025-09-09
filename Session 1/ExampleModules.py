# This code should be saved as "ExampleModules.py"

def squareIt(x):
    return float(x)**2

def sqrtIt(x):
    if x>0:
        return float(x)**.5
    else :
        return None


class stockBeta():
    def __init__(self, beta):
        self.beta= beta

    def adjustBeta(self):
        return 0.66*self.beta + 0.33 * 1

    def squreIt(self):
        return self.beta**2


