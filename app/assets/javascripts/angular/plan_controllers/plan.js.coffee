angular.module('travel-components').controller 'PlanController'
, [
    '$scope', 'Trip', '$window', '$interval', '$cookies', 'Days'
  , ($scope, Trip, $window, $interval, $cookies, Days) ->
      $scope.uuid = ->
        s4 = ->
          return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
        return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();

      # define controller
      $scope.trip_id = (/trips\/([a-zA-Z0-9]+)/.exec($window.location)[1]);
      $scope.tripService = Trip.init($scope.trip_id)

      # tumblers
      $scope.activitiesCollapsed = true
      $scope.transfersCollapsed = true
      $scope.edit = false
      $scope.edit_persons_count = false

      # loaded indicators
      $scope.budget_loaded = false
      $scope.trip_loaded = false

      # show checkboxes

      $scope.restoreVisibilityFromCookie = (column) ->
        key = "#{$scope.trip_id}_#{column}"
        cookie_val = $cookies.get(key)
        if cookie_val == undefined
          $scope[column] = true
        else
          $scope[column] = cookie_val == 'true'

      $scope.saveVisibilityToCookie = (column) ->
        key = "#{$scope.trip_id}_#{column}"
        $cookies.put(key, $scope[column])

      $scope.changeVisibility = (column) ->
        $scope[column] = !$scope[column]
        $scope.saveVisibilityToCookie(column)

      for column in ['show_place', 'show_transfers', 'show_hotel']
        $scope.restoreVisibilityFromCookie(column)

      # budget
      $scope.budget = 0

      $scope.tripService.getCountries($scope.trip_id).then (data) ->
        $scope.countries = data.countries

      promise = $interval(
        () ->
          $.ajax({
            url: "/api/user_shows/#{$scope.trip_id}",
            type: 'GET',
            success: (data) ->
              $scope.users = data
            error: ->
              $interval.cancel(promise)
          })
      ,
        10000
      )

      $scope.init = (count) ->
        $scope.days = new Array(count) unless count == 0

      $scope.initCatering = () ->
        $scope.tripService.getCaterings().then (caterings) ->
          $scope.caterings = caterings

      $scope.fillAsPreviousPlace = (place, place_index, day, day_index) ->
        if day.places[place_index - 1]
          prev_place = day.places[place_index - 1]
        else
          prev_day = $scope.days[day_index - 1]
          prev_place = prev_day.places[prev_day.places.length - 1]
        place.city_id = prev_place.city_id
        place.city_text = prev_place.city_text
        place.flag_image = prev_place.flag_image

      $scope.fillAsPreviousHotel = (hotel, day_index) ->
        prev_day = $scope.days[day_index - 1]
        prev_hotel = prev_day.hotel
        if prev_hotel
          hotel.name = prev_hotel.name
          hotel.amount_cents = prev_hotel.amount_cents
          hotel.amount_currency = prev_hotel.amount_currency
          hotel.amount_currency_text = prev_hotel.amount_currency_text
          hotel.links = []
          for link in prev_hotel.links
            hotel.links.push JSON.parse(JSON.stringify(link))

      # REST: methods using old API
      $scope.loadBudget = ->
        $scope.tripService.getBudget($scope.trip_id).then (budget) ->
          $scope.budget = budget.sum
          $scope.transfers_hotel_budget = budget.transfers_hotel_budget
          $scope.activities_other_budget = budget.activities_other_budget
          $scope.catering_budget = budget.catering_budget

          $scope.budget_loaded = true

      $scope.loadCountries = ->
        $scope.tripService.getCountries($scope.trip_id).then (data) ->
          $scope.countries = data.countries

      $scope.loadTrip = ->
        $scope.tripService.getTrip().then (trip) ->
          $scope.trip = trip

          $scope.trip_loaded = true
          $scope.edit_persons_count = false

      $scope.savePlan = ->
        return if $scope.saving
        $scope.saving = true
        $scope.tripService.updateTrip($scope.trip).then ->
          $scope.saving = false unless $scope.days || $scope.caterings || $scope.planDays
        if $scope.days
          $scope.tripService.createDays($scope.days).then ->
            $scope.saving = false
            $scope.loadBudget()
            $scope.loadCountries()
        if $scope.caterings
          $scope.tripService.createCaterings($scope.caterings).then ->
            $scope.saving = false
            $scope.loadBudget()
            $scope.loadCountries()
        if $scope.planDays
          Days.saveWithActivities($scope.trip_id, $scope.planDays).success ->
            $scope.saving = false
            toastr["success"]($('#notification_saved').text());
            $scope.loadBudget()
            $scope.loadCountries()


      $scope.saveTrip = ->
        $scope.tripService.updateTrip($scope.trip).then ->
          $scope.edit_persons_count = false

      $scope.cancelEdits = ->
        $scope.setEdit(false)
        if $scope.days
          for day in $scope.days
            $scope.tripService.reloadDay day
        if $scope.caterings
          $scope.tripService.getCaterings().then (caterings) ->
            $scope.caterings = caterings
        if $scope.planDays
          $scope.planDays = []
          Days.getActivities($scope.trip_id).then (response) ->
            for day in response.data.days
              $scope.planDays.push day
              $scope.$broadcast('day_activities_updated', day)

        $scope.loadTrip()
        $scope.loadBudget()
        $scope.loadCountries()
      # END OF API

      # NEW EPOCH CODE - WILL SURVIVE

      # days of the plan gathered from child controllers
      $scope.planDays = []

      $scope.initActivities = ->
        Days.getActivities($scope.trip_id).then (response) ->
          for day in response.data.days
            $scope.planDays.push day
            $scope.$broadcast('day_activities_loaded', day)

      $scope.$on('day_activities_reloaded', (event, day) ->
        $scope.planDays = $scope.planDays.filter (old_day) -> old_day.id != day.id
        $scope.planDays.push day
      )

      $scope.add = (field, obj = {}) ->
        obj['id'] = new Date().getTime()
        field.push(obj)

      $scope.remove = (field, index) ->
        field.splice(index, 1)

      $scope.setEdit = (val) ->
        $scope.edit = val
        # emit event
        $scope.$broadcast('whole_plan_edit', val)

      # END NEW EPOCH CODE

  ]
