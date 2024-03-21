import json
class Parser():
    @classmethod
    def parse(cls, file):
        json_dict = json.loads(open(file, 'r').read())
        return Config(json_dict)
class Config():
    def __init__(self, conf):
        for key,value in conf.items():
            if isinstance(value, dict):
                setattr(self, key, Config(value))
            elif isinstance(value, list):
                setattr(self, key, [Config(i) for i in value])
            else:
                setattr(self, key, value)
    def getitems(self):
        return list(vars(self))

    def asdict(self):
        output = {}
        for key,value in vars(self).items():
            if isinstance(value, Config):
                output[key]=value.asdict()
            elif isinstance(value, list):
                output[key]=[i.asdict() if isinstance(i, Config) else i for i in value]
            else:
                output[key]=value
        return output

    def write_to_file(self, filename):
        with open(filename, 'w+') as file:
            file.write(json.dumps(self.asdict()))


    def __getitem__(self, key):
        if isinstance(key, str):
            return getattr(self, key)

    def __setitem__(self, key, value):
        if isinstance(key, str):
            setattr(self, key, value)
    
if __name__ == "__main__":
    conf = Parser.parse('test.json')
    print(conf.asdict())
