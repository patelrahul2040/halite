$rootScope = null
mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'ConsoleCtlr', ['$scope', '$timeout', '$rootScope', '$location', '$route', '$q', '$filter',
    '$templateCache',
    'Configuration','AppData', 'AppPref', 'Item', 'Itemizer', 
    'Minioner', 'Resulter', 'Jobber', 'Runner', 'Wheeler', 'Commander', 'Pagerage',
    'SaltApiSrvc', 'SaltApiEvtSrvc', 'SessionStore', '$filter',
    ($scope, $timeout, $rootScope, $location, $route, $q, $filter, $templateCache, Configuration,
    AppData, AppPref, Item, Itemizer, Minioner, Resulter, Jobber, Runner, Wheeler, 
    Commander, Pagerage, SaltApiSrvc, SaltApiEvtSrvc, SessionStore ) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        #console.log("ConsoleCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""

        $scope.monitorMode = null

        $scope.graining = false
        $scope.pinging = false
        $scope.statusing = false
        $scope.eventing = false
        $scope.commanding = false
        $scope.docSearch = false

        if !AppData.get('commands')?
            AppData.set('commands', new Itemizer())
        $scope.commands = AppData.get('commands')

        if !AppData.get('jobs')?
            AppData.set('jobs', new Itemizer())
        $scope.jobs = AppData.get('jobs')

        if !AppData.get('minions')?
            AppData.set('minions', new Itemizer())
        $scope.minions = AppData.get('minions')

        if !AppData.get('events')?
            AppData.set('events', new Itemizer())
        $scope.events = AppData.get('events')

        $scope.snagCommand = (name, cmds) -> #get or create Command
            unless $scope.commands.get(name)?
                $scope.commands.set(name, new Commander(name, cmds))
            return ($scope.commands.get(name))

        $scope.snagJob = (jid, cmd) -> #get or create Jobber
            if not $scope.jobs.get(jid)?
                job = new Jobber(jid, cmd)
                $scope.jobs.set(jid, job)
            return ($scope.jobs.get(jid))

        $scope.snagRunner = (jid, cmd) -> #get or create Runner
            if not $scope.jobs.get(jid)?
                job = new Runner(jid, cmd)
                $scope.jobs.set(jid, job)
            return ($scope.jobs.get(jid))

        $scope.snagWheel = (jid, cmd) -> #get or create Wheeler
            if not $scope.jobs.get(jid)?
                job = new Wheeler(jid, cmd)
                $scope.jobs.set(jid, job)
            return ($scope.jobs.get(jid))

        $scope.snagMinion = (mid) -> # get or create Minion
            if not $scope.minions.get(mid)?
                $scope.minions.set(mid, new Minioner(mid))
            return ($scope.minions.get(mid))

        $scope.newPagerage = (itemCount) ->
            return (new Pagerage(itemCount))

        $scope.commandTarget = ""

        $scope.filterage =
            grains: ["any", "id", "host", "domain", "server_id"]
            grain: "any"
            target: ""
            express: ""

        $scope.setFilterGrain = (index) ->
            $scope.filterage.grain = $scope.filterage.grains[index]
            $scope.setFilterExpress()
            return true

        $scope.setFilterTarget = (target) ->
            $scope.filterage.target = target
            $scope.setFilterExpress()
            return true

        $scope.setFilterExpress = () ->
            #console.log "setFilterExpress"
            if $scope.filterage.grain is "any"
                #$scope.filterage.express = $scope.filterage.target
                regex = RegExp($scope.filterage.target, "i")
                $scope.filterage.express = (minion) ->
                    for grain in minion.grains.values()
                        if angular.isString(grain) and grain.match(regex)
                            return true

                    return false
            else
                regex = RegExp($scope.filterage.target,"i")
                name = $scope.filterage.grain
                $scope.filterage.express = (minion) ->
                    return minion.grains.get(name).toString().match(regex)
            return true

        $scope.eventReverse = true
        $scope.jobReverse = true
        $scope.commandReverse = false

        $scope.sortage =
            targets: ["id", "grains", "ping", "active"]
            target: "id"
            reverse: false

        $scope.setSortTarget = (index) ->
            $scope.sortage.target = $scope.sortage.targets[index]
            return true

        $scope.sortMinions = (minion) ->
            if $scope.sortage.target is "id"
                result = minion.grains.get("id")
            else if $scope.sortage.target is "grains"
                result = minion.grains.get($scope.sortage.target)?
            else
                result = minion[$scope.sortage.target]
            result = if result? then result else false
            return result

        $scope.sortJobs = (job) ->
            result = job.jid
            result = if result? then result else false
            return result

        $scope.sortEvents = (event) ->
            result = event.utag
            result = if result? then result else false
            return result

        $scope.sortCommands = (command) ->
            result = command.name
            result = if result? then result else false
            return result

        $scope.resultKeys = ["retcode", "fail", "success", "done"]

        $scope.expandMode = (ensual) ->
            if angular.isArray(ensual)
                for x in ensual
                    if angular.isObject(x)
                        return 'list'
                return 'vect'
            else if angular.isObject(ensual)
                return 'dict'
            return 'lone'

        $scope.ensuals = (ensual) ->
            #makes and array so we can create new scope with ng-repeat
            #work around to recursive scope expression for ng-include
            return ([ensual])

        $scope.actions =
            State:
                highstate:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.highstate'
                show_highstate:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.show_highstate'
                show_lowstate:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.running'
                running:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.running'
            Test:
                ping:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.ping'
                echo:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.echo'
                    arg: ['Hello World']
                conf_test:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.conf_test'
                fib:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.fib'
                    arg: [8]
                collatz:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.collatz'
                    arg: [8]
                sleep:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.sleep'
                    arg: ['5']
                rand_sleep:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.rand_sleep'
                    arg: ['max=10']
                get_opts:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.get_opts'
                providers:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.providers'
                version:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.version'
                versions_information:
                    mode: 'async'
                    tgt: '*'

        $scope.ply = (cmds) ->
            target = if $scope.commandTarget isnt "" then $scope.commandTarget else "*"
            unless angular.isArray(cmds)
                cmds = [cmds]
            for cmd in cmds
                cmd.tgt = target
            $scope.action(cmds)

        $scope.command =
            result: {}
            history: {}
            lastCmds: null
            cmd:
                mode: 'async'
                fun: ''
                tgt: '*'
                arg: [""]  
                expr_form: 'glob'

            size: (obj) ->
                return _.size(obj)

            addArg: () ->
                @cmd.arg.push('')
                #@cmd.arg[_.size(@cmd.arg)] = ""

            delArg: () ->
                if @cmd.arg.length > 1
                    @cmd.arg = @cmd.arg[0..-2]
                #if _.size(@cmd.arg) > 1
                 #   delete @cmd.arg[_.size(@cmd.arg) - 1]

            getArgs: () ->
                #return (val for own key, val of @cmd.arg when val isnt '')
                return (arg for arg in @cmd.arg when arg isnt '')

            getCmds: () ->
                if @cmd.fun.split(".").length == 3 # runner or wheel not minion job
                    cmds =
                    [
                        fun: @cmd.fun,
                        mode: @cmd.mode,
                        arg: @getArgs()
                    ]
                else 
                    cmds =
                    [
                        fun: @cmd.fun,
                        mode: @cmd.mode,
                        tgt: if @cmd.tgt isnt "" then @cmd.tgt else "",
                        arg: @getArgs(),
                        expr_form: @cmd.expr_form
                    ]

                return cmds

            humanize: (cmds) ->
                unless cmds
                    cmds = @getCmds()
                return (((part for part in [cmd.fun, cmd.tgt].concat(cmd.arg) \
                    when part? and part isnt '').join(' ') for cmd in cmds).join(',').trim())

        $scope.expressionFormats = 
            Glob: 'glob'
            'Perl Regex': 'pcre'
            List: 'list'
            Grain: 'grain'
            'Grain Perl Regex': 'grain_pcre'
            Pillar: 'pillar'
            'Node Group': 'nodegroup'
            Range: 'range'
            Compound: 'compound'

        $scope.$watch "command.cmd.expr_form", (newVal, oldVal, scope) ->
            if newVal == oldVal
                return
            if newVal == 'glob' 
                $scope.command.cmd.tgt = "*"
            else
                $scope.command.cmd.tgt = ""

        $scope.fixTarget = () ->
            if $scope.command.cmd.tgt? and $scope.command.cmd.expr_form == 'list' #remove spaces after commas
                $scope.command.cmd.tgt = $scope.command.cmd.tgt.replace(/,\s+/g,',')

        $scope.humanize = (cmds) ->
            unless angular.isArray(cmds)
                cmds = [cmds]
            return (((part for part in [cmd.fun, cmd.tgt].concat(cmd.arg) \
                    when part? and part isnt '').join(' ') for cmd in cmds).join(',').trim())

        $scope.action = (cmds) ->
            $scope.commanding = true
            if not cmds
                cmds = $scope.command.getCmds()
            command = $scope.snagCommand($scope.humanize(cmds), cmds)

            #console.log('Calling SaltApiSrvc.action')
            SaltApiSrvc.action($scope, cmds )
            .success (data, status, headers, config ) ->
                results = data.return
                for result, index in results
                    if not _.isEmpty(result)
                        parts = cmds[index].fun.split(".") # split on "." character
                        if parts.length == 3 
                            if parts[0] =='runner'
                                job = $scope.startRun(result, cmds[index]) #runner result is tag
                                command.jobs.set(job.jid, job)
                            else if parts[0] == 'wheel'
                                job = $scope.startWheel(result, cmds[index]) #runner result is tag
                                command.jobs.set(job.jid, job)
                        else
                            job = $scope.startJob(result, cmds[index])
                            command.jobs.set(job.jid, job)
                    $scope.commanding = false
                return true
            .error (data, status, headers, config) ->
                $scope.commanding = false

        $scope.fetchPings = (target, $q) ->
          defer = $q.defer()
          cmd =
            mode: "async"
            fun: "test.ping"
            tgt: target
          SaltApiSrvc.run($scope, cmd)
          .success (data, status, headers, config) ->
              result = data.return?[0]
              if result
                job = $scope.startJob(result, cmd)
                watchdogTimer = $timeout () ->
                  defer.reject "Timed out"
                , 6000
                job.commit($q)
                .then (donejob) ->
                    for {key: mid, val: result} in donejob.results.items()
                      if not result.fail and result.active
                        $timeout.cancel watchdogTimer
                        return defer.resolve mid
                      else
                        return defer.reject "Job failed or minion inactive"
              else
                return defer.reject "Run call did not get any results"
          .error (data, status, header, config) ->
              return defer.reject "Failed to connect to backend service"
          return defer.promise

        $scope.pruneMinions = (mids) ->
          toDeactivate = _.difference($scope.minions.keys(), mids)
          for mid in toDeactivate
            minion = $scope.snagMinion(mid)
            minion.unlinkJobs()
          $scope.minions?.filter mids
          return mids

        $scope.getWheelTag = ($q, $rootScope) ->
          defer = $q.defer()
          cmd =
            mode: "async"
            fun: "wheel.key.list_all"
          SaltApiSrvc.run($scope, cmd)
          .success (data, status, headers, config) ->
            defer.resolve data.return?[0]
          .error (reason) ->
            defer.reject reason
          return defer.promise

        $scope.getMinionListFromWheeler = (tag) ->
          cmd =
            mode: "async"
            fun: "wheel.key.list_all"
          wheel = $scope.startWheel(tag, cmd)
          watchdogTimer = $timeout () ->
              $scope.errorMsg = "Salt List All Call Timed out! Please fetch minion status again."
              throw {"err": "Timed out"}
            , 6000
          wheel.commit($q)
          .then (donejob) ->
              ret = []
              for {key: _key, val: result} in donejob.results.items()
                unless result.fail
                  $timeout.cancel(watchdogTimer)
                  ret = ret.concat result.return.minions
              return ret # list of minion_ids

        $scope.fetchActives = () ->
          $scope.getWheelTag($q, $rootScope)
          .then($scope.getMinionListFromWheeler)
          .then($scope.pruneMinions)
          .then (data) ->
            _.each data,  (item)->
              $scope.fetchPings(item, $q)
              .then((mid) ->
                minion = $scope.snagMinion(mid)
                minion.activize()
                $scope.$emit "Marshall", mid
              , (error) ->
                    $scope.errorMsg = "Failed to ping #{item}"
                )
          , (error) ->
                $scope.errorMsg = "There was an error trying to fetch actives"

        $scope.fetchGrains = (target) ->
            #target = if target then target else "*"
            cmd =
                mode: "async"
                fun: "grains.items"
                tgt: target
                expr_form: 'glob'
            if not target?
                minions = (minion.id for minion in $scope.minions.values() when minion.active is true)
                target = minions.join(',')
                cmd.tgt = target
                cmd.expr_form = 'list'


            $scope.graining = true
            SaltApiSrvc.run($scope, [cmd])
            .success (data, status, headers, config) ->
                #$scope.graining = false
                result = data.return?[0]
                if result
                    job = $scope.startJob(result, cmd)
                    job.commit($q).then (donejob) ->
                        $scope.assignGrains(donejob)

                return true
            .error (data, status, headers, config) ->
                $scope.graining = false
            return true

        $scope.assignGrains = (job) ->
            for {key: mid, val: result} in job.results.items()
                unless result.fail
                    grains = result.return
                    minion = $scope.snagMinion(mid)
                    minion.grains.reload(grains, false)
            $scope.graining = false
            return job   

        $scope.docsLoaded = false
        $scope.docKeys = []
        $scope.docSearchResults = ''
        $scope.docs = {}

        $scope.searchDocs = () ->
            if not $scope.command.cmd.fun? or not $scope.docSearch or $scope.command.cmd.fun == ''
                $scope.docSearchResults = ''
                return true
            matching = _.filter($scope.docKeys, (key) ->
                return key.indexOf($scope.command.cmd.fun.toLowerCase()) != -1)
            matchingDocs = (key + "\n" + $scope.docs[key] + "\n" for key in matching)
            $scope.docSearchResults = matchingDocs.join('')
            return true

        $scope.isSearchable = () ->
            return $scope.docsLoaded

        $scope.fetchDocsDone = (donejob) ->
            results = donejob.results
            minions = results._data
            minion_with_result = _.find(minions, (minion) ->
                minion.val.retcode == 0)
            if minion_with_result?
                $scope.docs = minion_with_result.val.return
                $scope.docKeys = for key, value of $scope.docs
                    "#{key.toLowerCase()}"
                $scope.docsLoaded = true
            else
                $scope.errorMsg = 'Docs not loaded since all minions returned invalid data. Please Check Minions And Retry.'
            return

        $scope.fetchDocsFailed = () ->
            $scope.errorMsg = 'Failed to fetch Docs. Please check system and retry'

        $scope.fetchDocs = (target) ->
            if not target
              target = '*'

            command =
                fun: 'sys.doc'
                mode: 'async'
                tgt: target
                expr_form: 'glob'

            # command = $scope.snagCommand($scope.humanize(commands), commands)
            SaltApiSrvc.run($scope, command)
            .success (data, status, headers, config) ->
                result = data.return?[0] #result is a tag
                if result

                    job = $scope.startJob(result, command) #runner result is a tag
                    job.commit($q).then($scope.fetchDocsDone, $scope.fetchDocsFailed)
                    return true
            .error (data, status, headers, config) ->
                return false
            return true

        $scope.startWheel = (tag, cmd) ->
#            console.log "Start Wheel #{$scope.humanize(cmd)}"
#            console.log tag
            parts = tag.split("/")
            jid = parts[2]
            job = $scope.snagWheel(jid, cmd)
            return job    

        $scope.startRun = (tag, cmd) ->
            #console.log "Start Run #{$scope.humanize(cmd)}"
            #console.log tag
            parts = tag.split("/")
            jid = parts[2]
            job = $scope.snagRunner(jid, cmd)
            return job

        $scope.startJob = (result, cmd) ->
            #console.log "Start Job #{$scope.humanize(cmd)}"
            #console.log result
            jid = result.jid
            job = $scope.snagJob(jid, cmd)
            job.initResults(result.minions)
            return job

        $scope.processJobEvent = (jid, kind, edata) ->
            job = $scope.jobs.get(jid)
            job.processEvent(edata)
            data = edata.data
            if kind == 'new'
                job.processNewEvent(data)
            else if kind == 'ret'
                minion = $scope.snagMinion(data.id)
                minion.activize() #since we got a return then minion must be active
                job.linkMinion(minion)
                job.processRetEvent(data)
                job.checkDone()
            return job

        $scope.processRunEvent = (jid, kind, edata) ->
            job = $scope.jobs.get(jid)
            job.processEvent(edata)
            data = edata.data
            if kind == 'new'
                job.processNewEvent(data)
            else if kind == 'ret'
                job.processRetEvent(data)
            return job

        $scope.processWheelEvent = (jid, kind, edata) ->
            job = $scope.jobs.get(jid)
            job.processEvent(edata)
            data = edata.data
            if kind == 'new'
                job.processNewEvent(data)
            else if kind == 'ret'
                job.processRetEvent(data)
            return job

        $scope.processMinionEvent = (mid, edata) ->
            minion = $scope.snagMinion(mid)
            minion.processEvent(edata)
            minion.activize()
            $scope.fetchGrains(mid)
            return minion

        $scope.processKeyEvent = (edata) ->
            data = edata.data
            mid = data.id
            minion = $scope.snagMinion(mid)
            if data.result is true
                if data.act is 'delete'
                    minion.unlinkJobs()
                    $scope.minions.del(mid)
            return minion

        $scope.stamp = () ->
            date = new Date()          
            stamp = [   "/#{date.getUTCFullYear()}",
                        "-#{('00' + date.getUTCMonth()).slice(-2)}",
                        "-#{('00' + date.getUTCDate()).slice(-2)}",
                        "_#{('00' + date.getUTCHours()).slice(-2)}",
                        ":#{('00' + date.getUTCMinutes()).slice(-2)}",
                        ":#{('00' + date.getUTCSeconds()).slice(-2)}",
                        ".#{('000' + date.getUTCMilliseconds()).slice(-3)}"].join("")
            return stamp

        $scope.processSaltEvent = (edata) ->
            #console.log "Process Salt Event: "
            #console.log edata
            if not edata.data._stamp?
                edata.data._stamp = $scope.stamp()
            edata.utag = [edata.tag, edata.data._stamp].join("/")
            $scope.events.set(edata.utag, edata)
            parts = edata.tag.split("/") # split on "/" character
            if parts[0] is 'salt'
                if parts[1] is 'job'
                    jid = parts[2]
                    if jid != edata.data.jid
                        console.log "Bad job event"
                        $scope.errorMsg = "Bad job event: JID #{jid} not match #{edata.data.jid}"
                        return false
                    $scope.snagJob(jid, edata.data)
                    kind = parts[3]
                    $scope.processJobEvent(jid, kind, edata)

                else if parts[1] is 'run'
                    jid = parts[2]
                    if jid != edata.data.jid
                        console.log "Bad run event"
                        $scope.errorMsg = "Bad run event: JID #{jid} not match #{edata.data.jid}"
                        return false
                    $scope.snagRunner(jid, edata.data)
                    kind = parts[3]
                    $scope.processRunEvent(jid, kind, edata)

                else if parts[1] is 'wheel'
                    jid = parts[2]
                    if jid != edata.data.jid
                        console.log "Bad wheel event"
                        $scope.errorMsg = "Bad wheel event: JID #{jid} not match #{edata.data.jid}"
                        return false
                    $scope.snagWheel(jid, edata.data)
                    kind = parts[3]
                    $scope.processWheelEvent(jid, kind, edata)

                else if parts[1] is 'minion' or parts[1] is 'syndic'
                    mid = parts[2]
                    if mid != edata.data.id
                        console.log "Bad minion event"
                        $scope.errorMsg = "Bad minion event: MID #{mid} not match #{edata.data.id}"
                        return false
                    $scope.processMinionEvent(mid, edata)

                 else if parts[1] is 'key'
                    $scope.processKeyEvent(edata)

            return edata

        $scope.openEventStream = () ->
            $scope.eventing = true
            $scope.eventPromise = SaltApiEvtSrvc.events($scope, 
                $scope.processSaltEvent, "salt/")
            .then (data) ->
                #console.log "Opened Event Stream: "
                #console.log data
                $scope.$emit('Activate')
                $scope.eventing = false
            , (data) ->
                console.log "Error Opening Event Stream"
                #console.log data
                if SessionStore.get('loggedIn') == false
                    $scope.errorMsg = "Cannot open event stream! Must login first!"
                else
                    $scope.errorMsg = "Cannot open event stream!"
                $scope.eventing = false
                return data
            return true

        $scope.closeEventStream = () ->
            #console.log "Closing Event Stream"
            SaltApiEvtSrvc.close()
            return true

        $scope.clearSaltData = () ->
            AppData.set('commands', new Itemizer())
            $scope.commands = AppData.get('commands')
            AppData.set('jobs', new Itemizer())
            $scope.jobs = AppData.get('jobs')
            AppData.set('minions', new Itemizer())
            $scope.minions = AppData.get('minions')
            AppData.set('events', new Itemizer())
            $scope.events = AppData.get('events')

        $scope.authListener = (event, loggedIn) ->
            #console.log "Received #{event.name}"
            #console.log event
            if loggedIn
                $scope.openEventStream()
            else
                $scope.closeEventStream()
                $scope.clearSaltData()
            return true


        $scope.activateListener = (event) ->
            #console.log "Received #{event.name}"
            #console.log event
            $scope.$emit "Marshall"


        $scope.marshallListener = (event, mid) ->
#            console.log "Received #{event.name}"
#            console.log event
            if mid?
              $scope.fetchGrains(mid)
              $scope.fetchDocs(mid)
            else
              $scope.fetchActives()

        $scope.$on('ToggleAuth', $scope.authListener)
        $scope.$on('Activate', $scope.activateListener)
        $scope.$on('Marshall', $scope.marshallListener)

        if not SaltApiEvtSrvc.active and SessionStore.get('loggedIn') == true
            $scope.openEventStream()

        $scope.testClick = (name) ->
            console.log "click #{name}"

        $scope.testFocus = (name) ->
            console.log "focus #{name}"

        return true
    ]
