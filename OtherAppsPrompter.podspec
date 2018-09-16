
Pod::Spec.new do |s|
  s.name             = 'OtherAppsPrompter'
  s.version          = '0.1.3'
  s.summary          = 'Shows a list of macOS apps that a user can link to in the App Store.'

  s.description      = <<-DESC
  Prompts for users to sign up to your mailing list, using the MailGun API.
                       DESC

  s.homepage         = 'https://github.com/megatron1000/OtherAppsPrompter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'megatron1000' => 'mark@bridgetech.io' }
  s.source           = { :git => 'https://github.com/megatron1000/OtherAppsPrompter.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/markbridgesapps'

  s.platform     = :osx, '10.11'
  
  s.dependency 'Kingfisher', '> 4'

  s.source_files = 'OtherAppsPrompter/Classes/**/*'

  s.resource_bundles = {
    'OtherAppsPrompter' => ['OtherAppsPrompter/Assets/**/*']
  }

end
