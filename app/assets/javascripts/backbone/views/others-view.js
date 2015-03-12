/*global Backbone, jQuery, _, ENTER_KEY, ESC_KEY */
var app = app || {};

(function ($) {
  'use strict';

  app.OthersView = app.BaseView.extend({
    el: $('#todoapp'),

    events: {
      'submit #chart-form' : 'handleSubmit'
    },

    socket_events: {
       "todo message" : "addTodoMessage",
       "chart message" : "addChartMessage",
       "join message" : "addJoninMessage",
       "leave message" : "addLeaveMessage"
    },

    render: function () {
      $('#todoapp').html(_.template($('#t-others').html()));
      // this.updateJoiners();
    },

    updateJoiners: function () {
      $('.alert-container').html(_.template($('#t-joiners').html())({users: app.joiners.join(',')}));
    },

    handleSubmit: function (e) {
      e.preventDefault();
      var $this = $(e.currentTarget);

      var text = $this.find('input').val();
      if (text.length > 0) {
        var data = {
          text: $this.find('input').val(),
          username: app.username,
          time: (new Date()).toString()
        };
        app.socket.emit('add chart', JSON.stringify(data));
        $this.find('input').val('');
      }
    },

    addTodoMessage: function (msg) {
      var data = $.parseJSON(msg);
      var date = new Date(data.time);
      data.time = date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
      if (data.username == app.username) {
        $("#message-list").prepend(_.template($('#t-my-message').html())(data));
      } else {
        $("#message-list").prepend(_.template($('#t-message').html())(data));
      }
    },

    addChartMessage: function (msg) {
      var data = $.parseJSON(msg);
      var date = new Date(data.time);
      data.time = date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
      if (data.username == app.username) {
        $("#message-list").prepend(_.template($('#t-chart-my-message').html())(data));
      } else {
        $("#message-list").prepend(_.template($('#t-chart-message').html())(data));
      }
    },

    addJoninMessage: function () {
      var msg = app.username + '   加入';
      if (app.joiners.indexOf(app.username) < 0) {
        app.joiners.push(app.username);
        this.updateJoiners();
      }
      $("#message-list").prepend(_.template($('#t-alert-success').html())({msg: msg}));
    },

    addLeaveMessage: function () {
      var msg = app.username + '   离开';
      if (app.joiners.indexOf(app.username) > 0) {
        var index = app.joiners.indexOf(app.username);
        app.joiners.splice(index);
        this.updateJoiners();
      }
      $("#message-list").prepend(_.template($('#t-alert-error').html())({msg: msg}));
    }
  });
})(jQuery);
