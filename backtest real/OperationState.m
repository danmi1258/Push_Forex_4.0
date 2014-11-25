classdef OperationState
    
    properties
        actualOperation;
        phase;
        lastOperation;
        lock;
        lockDuration;
        counter;
    end
    
    methods
        function obj = OperationState
            obj.actualOperation = 0;
            obj.phase           = 0;
            obj.lastOperation   = 0;
            obj.lock            = 0;
            obj.counter         = 0;
            obj.lockDuration    = 0;
        end
    end
    
end
