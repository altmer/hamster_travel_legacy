(function(){angular.module("travel-services").config(["railsSerializerProvider",function(t){return t.underscore(angular.identity).camelize(angular.identity)}]).service("Trip",["railsResourceFactory",function(t){return{init:function(r){return{trip_id:r,Days:t({url:"/api/trips/"+r+"/days",name:"days"}),Trips:t({url:"/api/trips",name:"trip"}),getDays:function(){return this.Days.query()},getDay:function(t){return this.Days.get(t)},createDays:function(t){return new this.Days(t).create()},updateDay:function(t){return new this.Days(t).update()},reloadDay:function(t,r){return null==r&&(r=null),this.getDay(t.id).then(function(e){var i,n,a,u;for(u=["places","transfers","hotel","comment","activities","add_price"],n=0,a=u.length;a>n;n++)i=u[n],t[i]=e[i];return r?r(t):void 0})},getTrip:function(){return this.Trips.get(this.trip_id)},updateTrip:function(t){return new this.Trips(t).update()}}}}}])}).call(this);