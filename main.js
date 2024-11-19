function getArticle() {
  const article = articles[Math.floor(Math.random() * articles.length)];
  // console.log(article);
  return article;
}

function redirectToArticle(article) {
  const urlPrefix = 'https://en.wikipedia.org/wiki';
  const articleSuffix = article;
  window.location.href = `${urlPrefix}/${articleSuffix}`;
}

function countdownAndExecute(countdownInSeconds, callback) {
  const countdownElement = document.getElementById('countdown');

  const intervalId = setInterval(() => {
    countdownElement.innerHTML = countdownInSeconds;
    countdownInSeconds--;

    if (countdownInSeconds < 0) {
      clearInterval(intervalId);
      callback();
    }
  }, 1200);
}


!function main() {
  const article = getArticle();
  countdownAndExecute(5, () => redirectToArticle(article));
}();
