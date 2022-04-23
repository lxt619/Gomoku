<template>
  <div id="app">
    <button class="admit" @click="admit()">Admit defeat</button>
    <div id="content">
      <h2 class="gameTitle">Gomoku Game</h2>
      <div class="main">
        <canvas id="myCanvas" ref="canvas" width="480" height="480"></canvas>
      </div>
      <div class="actionButtons">
        <button class="backChess" @click="backChess()">Withdraw</button>
        <button class="cancelBackChess" @click="cancelBackChess()">Cancel Withdraw</button>
      </div>
    </div>
    <!-- Use model component of iView to show the modal dialog of game ending -->
    <Modal v-model="showModal" title="alert" @on-ok="ok" @on-cancel="cancel">
      <p class="successText">{{ win }}</p>
      <div slot="footer">
        <Button
          type="success"
          size="large"
          long
          :loading="modal_loading"
          @click="reStart"
          >Restart</Button
        >
      </div>
    </Modal>
  </div>
</template>
<script>
export default {
  name: "home",
  data() {
    return {
      // Define a mode array that checks whether eight directions around a chess have the same color
      directionMode: [
        [1, 0], //horizontal
        [0, 1], //vertical
        [1, 1], //left oblique line
        [1, -1], //right oblique line
      ],
      step: 0, // current chess step
      chessMapArr: [], // Array of current chess on the canva
      chessColor: ["black", "white"], // Define white or black chess
      historyPos: [], // chess history location
      hisValArr: [], // Cancel withdraw but the kept array
      stepHis: 0,
      showModal: false, // If show 'game end' modal dialog
      endFlag: false, // If show 'game end'
      win: "",
    };
  },
  mounted() {
    const hasCan = document.getElementById("myCanvas");
    if (!hasCan.getContext) {
      this.$alert("Current server doesn't support Canvas, please try another server.", "alert");
    } else {
      this.drawChessBoard();
      const canvas = this.$refs.canvas;
      // add events on board
      canvas.addEventListener("click", (item) => {
        if (this.endFlag) {
          this.$alert("Game over, restart?", "alert");
          return;
        }
        if (
          item.offsetX < 25 || item.offsetX > 450 || item.offsetY < 25 || item.offsetY > 450
        ) {
          return;
        }
        let cx = Math.floor((item.offsetX + 15) / 30) * 30;
        let cy = Math.floor((item.offsetY + 15) / 30) * 30;
        if (this.chessMapArr[cx / 30 - 1][cy / 30 - 1] == 0) {
          this.drawChess(cx, cy, this.chessColor[this.step % 2]);
          // Define chess location
          this.chessMapArr[cx / 30 - 1][cy / 30 - 1] = this.chessColor[this.step % 2];
          this.historyPos.length = this.step;
          this.historyPos.push({
            cx,
            cy,
            color: this.chessColor[this.step % 2],
          });
          this.hisValArr.push({
            cx,
            cy,
            color: this.chessColor[this.step % 2],
          });
          this.stepHis++;

          for (var m = 0; m < 4; m++) {
            this.judgeWin(
              cx / 30 - 1,
              cy / 30 - 1,
              this.chessColor[this.step % 2],
              this.directionMode[m]
            );
          }
          this.step++;
        } else {
          this.$alert("You cannot put it here！", "alert");
        }
      });
    }
  },
  methods: {
    // Initially define an empty board array
    initArr() {
      for (let m = 0; m < 15; m++) {
        this.chessMapArr[m] = [];
        for (let n = 0; n < 15; n++) {
          this.chessMapArr[m][n] = 0;
        }
      }
    },
    // draw board
    drawChessBoard() {
      // initially empty board
      this.initArr();
      // use canvas to draw board
      let canvas = this.$refs.canvas;
      let context = canvas.getContext("2d");
      context.strokeStyle = "#666";
      for (let m = 0; m < 15; m++) {
        context.beginPath();
        context.moveTo((m + 1) * 30, 30);
        context.lineTo((m + 1) * 30, canvas.height - 30);
        context.closePath();
        context.stroke();
        context.beginPath();
        context.moveTo(30, (m + 1) * 30);
        context.lineTo(canvas.width - 30, (m + 1) * 30);
        context.closePath();
        context.stroke();
      }
    },
    // draw chess
    drawChess(x, y, color) {
      let canvas = this.$refs.canvas;
      let context = canvas.getContext("2d");
      context.beginPath();
      context.arc(x, y, 15, 0, Math.PI * 2, false);
      context.closePath();
      context.fillStyle = color;
      context.fill();
    },
    // judge win or lose
    judgeWin(x, y, color, mode) {
      console.log(
        x,
        y,
        color,
        mode
      );
      let count = 1;
      // The two for loops judge whether there are chess pieces of the same color in the eight directions around the chess piece according to the defined directionMode array, and record the count of the same color.
      for (let m = 1; m < 5; m++) {
        if (this.chessMapArr[x + m * mode[0]]) {
          if (this.chessMapArr[x + m * mode[0]][y + m * mode[1]] == color) {
            count++;
          } else {
            break;
          }
        }
      }
      for (let n = 1; n < 5; n++) {
        if (this.chessMapArr[x - n * mode[0]]) {
          if (this.chessMapArr[x - n * mode[0]][y - n * mode[1]] == color) {
            count++;
          } else {
            break;
          }
        }
      }
      // If the same color on the board equal or larger than 5 and fit the win condition, then win
      if (count >= 5) {
        if (color == "black") {
          this.win = "Black WIN!";
          this.showModal = true;
        } else {
          this.win = "White WIN!";
          this.showModal = true;
        }
        this.endFlag = true;
      }
    },
    // redraw
    reDraw() {
      let canvas = this.$refs.canvas;
      let context = canvas.getContext("2d");
      context.fillStyle = "rgb(185, 168, 145)";
      context.fillRect(0, 0, canvas.width, canvas.height);
      context.beginPath();
      context.closePath();
    },
    // restart
    reStart() {
      this.reDraw();
      this.drawChessBoard();
      this.endFlag = false;
      this.step = 0;
      this.stepHis = 0;
      this.hisValArr = [];
      this.historyPos = [];
      this.showModal = false;
    },
    // withdraw
    backChess() {
      if (this.historyPos.length && !this.endFlag) {
        this.historyPos.pop(); // delete the last chess
        this.reDraw(); // redraw
        this.drawChessBoard(); // draw board
        // draw chess
        this.historyPos.forEach((e) => {
          this.drawChess(e.cx, e.cy, e.color);
          this.chessMapArr[e.cx / 30 - 1][e.cy / 30 - 1] = e.color;
        });
        this.step--;
      } else {
        this.$alert("You cannot cancel withdraw", "alert");
      }
    },
    // cancel withdraw
    cancelBackChess() {
      if (this.hisValArr.length > this.historyPos.length && !this.endFlag) {
        this.historyPos.push(this.hisValArr[this.step]);
        this.reDraw();
        this.drawChessBoard();
        this.historyPos.forEach((e) => {
          this.drawChess(e.cx, e.cy, e.color);
          this.chessMapArr[e.cx / 30 - 1][e.cy / 30 - 1] = e.color;
        });
        this.step++;
      } else {
        this.$alert("You cannot cancel withdraw", "alert");
      }
    },
    // admit defeat
    admit() {
      if (this.endFlag) {
        this.$alert("Game over, restart?", "alert");
      } else {
        this.endFlag = true;
        this.$alert("You already admit defeat, restart?", "game end");
        this.reDraw();
        this.drawChessBoard();
        this.endFlag = false;
        this.step = 0;
        this.stepHis = 0;
        this.hisValArr = [];
        this.historyPos = [];
      }
    },
  },
};
</script>
<style scoped="scoped">
@import url("../../static/css/chess.css");
</style>
