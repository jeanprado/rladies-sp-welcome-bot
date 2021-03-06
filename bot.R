library(telegram.bot)
library(stringr)
try(source('token.R'), silent=T) # bot token (hidden with .gitignore)

# saves bot token and updaters --------------------------------------------
bot <- Bot(token = bot_token("RLadiesSP"))
updater <- Updater(token = bot_token("RLadiesSP"))
updates <- bot$getUpdates()

# creates command to kill bot ---------------------------------------------
kill <- function(bot, update){
  bot$sendMessage(chat_id = update$message$chat_id,
                  text = "Parando por aqui...")
  # Clean 'kill' update
  bot$getUpdates(offset = update$update_id + 1L)
  # Stop the updater polling
  updater$stop_polling()
}

updater <<- updater + CommandHandler("kill", kill,
                                     as.BaseFilter(function(message) message$from_user  == "15366329"))

# defines welcome message -------------------------------------------------
welcome_text <- "*R-Ladies é uma organização que promove a diversidade de gênero na comunidade da linguagem R.* Integramos a organização R-Ladies Global, em São Paulo.

Nosso principal objetivo é *promover a linguagem computacional estatística R compartilhando conhecimento, assim, qualquer pessoa com interesse na linguagem é bem-vinde*, independente do nível de conhecimento 🥰

Nosso **público-alvo são as minorias de gênero**, portanto, mulheres cis ou trans, homens trans, bem como pessoas não-binárias e queer.

Buscamos fazer deste espaço um lugar seguro de aprendizado, então, sinta-se livre para fazer perguntas e saiba que não toleramos nenhuma forma de assédio.

• *Já faz parte da nossa comunidade no Meetup?* Nela, você fica sabendo em primeira mão dos nossos eventos. *Se ainda não fizer, entra aqui: https://bit.ly/RLadiesSP*.

Obrigada! 💖"

# sends welcome message ---------------------------------------------------
welcome <- function(bot, update){
  escape_username <- str_replace_all(update$message$new_chat_participant$username, c("\\*"="\\\\*", "_"="\\\\_"))
  welcome_message <- paste0('Seja bem-vinde, ', update$message$new_chat_participant$first_name,
                            ' (@', escape_username,')! \n\n', welcome_text)
  
  if (length(update$message$new_chat_participant) > 0L) {
    bot$sendMessage(chat_id = update$message$chat_id, text = welcome_message,
                    disable_web_page_preview = T, parse_mode="Markdown")
  }
}

updater <- updater + MessageHandler(welcome, MessageFilters$all)

# starts bot --------------------------------------------------------------
updater$start_polling()