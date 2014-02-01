local Record = class('Record')

function Record:ctor()
end

function Record:start()
    self.records_ = {}
end

function Record:trigger(evt)
    table.insert(self.records_, evt)
end

function Record:end()
    return self.records_
end