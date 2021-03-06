# discordrb api
require 'discordrb'

# services
require_relative 'services/discord_message_sender'

# config module
require_relative './config'

# modules
require_relative 'modules/self_roles'
require_relative 'modules/purge'
require_relative 'modules/equation'
require_relative 'modules/year'
require_relative 'modules/where_is'
require_relative 'modules/say'
require_relative 'modules/prompt'
require_relative 'modules/jail'
require_relative 'modules/train'

class Main
  # startup sequence
  bot = Discordrb::Commands::CommandBot.new(
    token: Config::API_TOKEN,
    client_id: Config::API_CLIENT_ID,
    prefix: Config::PREFIX,
  )

  # set the game the bot plays to `~help`
  bot.ready do
    bot.game = '~help'
    bot.debug = Config::DEBUG
  end

  # help command
  # no need to featurize that
  bot.command(:help) do |event|
    fields = []
    fields << Discordrb::Webhooks::EmbedField.new(
      name: "General Commands",
      value:
        "**`~year 1-4, masters, alumni`** - add your current academic status to your profile.\n"\
        "**`~purge 2-99`** - remove the last `n` messages in channel (**admin only**)\n"\
        "**`~equation your-latex-command`** - returns an image of a latex equation.\n"\
        "**`~help`** - return the help menu\n"\
        "\n\u200B"
    )

    fields << Discordrb::Webhooks::EmbedField.new(
      name: "Building Search Commands",
      value:
        "**`~whereis buildingName`** or **`~whereis buildingCode`** - return building details and location on map\n"\
        "**`~whereis list`** - return the list of all building codes and their associating names\n"
    )

    DiscordMessageSender.send_embedded(
      event.channel,
      title: "Help Menu",
      fields: fields,
    )
  end

  if Config::FEATURES["prompt"]
    bot.include! Prompt
  end
  
  # say featurization
  # run when command is ~say
  if Config::FEATURES["say"]
    bot.include! Say
  end

  # equation featurization
  # run when command is ~equation
  if Config::FEATURES["equation"]
    bot.include! Equation
  end

  # whereis featurization
  # runs when command is ~whereis
  if Config::FEATURES["whereis"]
    bot.include! WhereIs
  end

  # purge featurization
  # runs when command is ~purge
  if Config::FEATURES["purge"]
    bot.include! Purge
  end

  # year featurization
  # runs when command is ~year
  if Config::FEATURES["year"]
    bot.include! Year
  end

  # self roles featurization
  if Config::FEATURES['selfRoles']
    bot.include! SelfRoles
  end

  # jail/free commands featurization
  # wraps provided text in a jail cell
  if Config::FEATURES['jail']
	bot.include! Jail
  end
  
  # train featurization
  # train prints the sl command's train in a code block
  if Config::FEATURES['train']
	bot.include! Train
  end
  
  puts "This bot's invite URL is #{bot.invite_url}."
  puts 'Click on it to invite it to your server.'

  bot.run

  # to gracefully shutdown
  at_exit { bot.stop }
end
