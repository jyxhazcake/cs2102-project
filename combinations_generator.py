import itertools

def compute_list(list):
    for L in range(len(list)+1):
        for subset in itertools.combinations(list, L):
            print("compute closure of {", end = "")
            result = ", ".join(subset)
            print(result, end = "")
            print("}")

compute_list(['a', 'b', 'c', 'd'])