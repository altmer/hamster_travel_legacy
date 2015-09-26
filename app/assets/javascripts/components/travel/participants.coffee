angular.module('travel-components').controller 'ParticipantsController'
, [
    '$scope', '$location', '$window', '$http'
  , ($scope, $location, $window, $http) ->

      $scope.loadParticipants = ->
        $http.get("/api/participants?id=#{$scope.$parent.trip_id}").success (data) ->
          $scope.participants = data.users
          $scope.invited = data.invited_users

      $scope.selectUser = ($item, $model, $label, $scope) ->
        $scope.toggle()

        $http.post('/api/trip_invites', {id: $scope.$parent.trip_id, user_id: $item.code}).success (data) ->
          $scope.loadParticipants()

      $scope.deleteUser = (user_id) ->
        $http.delete("/api/trip_invites/#{$scope.$parent.trip_id}?user_id=#{user_id}").success (data) ->
          $scope.loadParticipants()

      $scope.deleteInvitedUser = (user_id) ->
        $http.delete("/api/trip_invites/#{$scope.$parent.trip_id}?trip_invite_id=#{user_id}").success (data) ->
          $scope.loadParticipants()
  ]