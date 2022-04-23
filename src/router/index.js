import Vue from 'vue'
import Router from 'vue-router'
import chess from '../page/chess.vue'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'chess',
      component: chess,
      redirect:'/chess'
    },
    {
      path: '/chess',
      name: 'chess',
      component: chess
    }
  ]
})
