<a name="readme-top"></a>


<h1 align="center"> Hasura Connect Cache Interceptor.</h1>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="images/logo.png" alt="Logo" width="180">
  </a>
<br></br>
  <p align="center">
  Implements in memory cache interceptors for Hasura_Connect.
    <br />
    <!-- <a href="https://github.com/othneildrew/Best-README-Template"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
    <!-- <a href="https://github.com/othneildrew/Best-README-Template">View Demo</a> 
    ·-->
    <a href="https://github.com/othneildrew/Best-README-Template/issues">Report Bug</a>
    ·
    <a href="https://github.com/othneildrew/Best-README-Template/issues">Request Feature</a>
  </p>

<br>

<!--  SHIELDS  ---->

[![License](https://img.shields.io/github/license/flutterando/hasura_connect?style=plastic)](https://github.com/Flutterando/hasura_connect/blob/master/LICENSE)
[![Pub Points](https://img.shields.io/pub/points/hasura_connect?label=pub%20points&style=plastic)](https://pub.dev/packages/hasura_connect/score)
[![Contributors](https://img.shields.io/github/contributors/flutterando/hasura_connect?style=plastic)](https://github.com/Flutterando/hasura_connect/graphs/contributors)
[![Forks](https://img.shields.io/github/forks/flutterando/hasura_connect?color=yellowgreen&logo=github&style=plastic)](https://github.com/Flutterando/hasura_connect/graphs/contributors)

[![Pub Publisher](https://img.shields.io/pub/publisher/hasura_connect?style=plastic)](https://pub.dev/publishers/flutterando.com.br/packages)
[![Flutterando Youtube](https://img.shields.io/youtube/channel/subscribers/UCplT2lzN6MHlVHHLt6so39A?color=blue&label=Flutterando&logo=YouTube&logoColor=red&style=plastic)](https://www.youtube.com/flutterando)
</div>

<br>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#sponsors">Sponsors</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<br>

<!-- ABOUT THE PROJECT -->
## About The Project

<br>
<!-- <Center>
<img src="images/Example-uno.png" alt="Uno PNG" width="400">
</Center> -->

<br>

Implements in memory cache interceptors for Hasura_Connect and provides interfaces to create you own implementation.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- SPONSORS -->
## Sponsors

<a href="https://fteam.dev">
    <img src="images/sponsor-logo.png" alt="Logo" width="180">
  </a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<br>


<!-- GETTING STARTED -->
## Getting Started

To install Hasura Connect and Hasura Cache Interceptor in your project you can follow the instructions below:

* In Memory Cache (without persistence)

a) Add in your pubspec.yaml:
   ```yaml
   dependencies:
  hasura_connect: <last version>
  hasura_cache_interceptor: <last version>
   ```
   
b)    or use slidy:
   ```sh
   slidy install hasura_connect, hasura_cache_interceptor
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## How To Use

A simple usage example:

```dart
import 'package:hasura_cache_interceptor/hasura_hive_cache_interceptor.dart';

final storage = MemoryStorageService();
final cacheInterceptor = CacheInterceptor(storage);
final hasura = HasuraConnect(
  "<your hasura url>",
  interceptors: [cacheInterceptor],
  httpClient: httpClient,
)
```

## Official Implementations
- Using Shared Preferences [[shared_preferences_cache_interceptor]](https://pub.dev/packages/shared_preferences_cache_interceptor)
- Using Hive [[hasura_hive_cache_interceptor]](https://pub.dev/packages/hive_cache_interceptor)
- [[others]](https://pub.dev/packages?q=dependency%3hasura_cache_interceptor)


_For more examples, please refer to the 🚧 [Documentation](https://example.com) - Currently being updated 🚧 .

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Features


- ✅ Memory cache interceptors.
- ✅ Custom interface.


Right now this package has concluded all his intended features. If you have any suggestions or find something to report, see below how to contribute to it.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTRIBUTING -->
## Contributing

🚧 [Contributing Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md) - Currently being updated 🚧

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the appropriate tag. 
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Remember to include a tag, and to follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) and [Semantic Versioning](https://semver.org/) when uploading your commit and/or creating the issue. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Flutterando Community
- [Discord](https://discord.gg/qNBDHNARja)
- [Telegram](https://t.me/flutterando)
- [Website](https://www.flutterando.com.br/)
- [Youtube Channel](https://www.youtube.com.br/flutterando)
- [Other useful links](https://linktr.ee/flutterando)


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Contributors 

<a href="https://github.com/flutterando/hasura_connect/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=flutterando/hasura_connect" />
</a>
<!-- Bot para Lista de contribuidores - https://allcontributors.org/  -->
<!-- Opção (utilizada no momento): https://contrib.rocks/preview?repo=flutterando%2Fasuka -->


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Maintaned by

---

<br>
<p align="center">
  <a href="https://www.flutterando.com.br">
    <img width="110px" src="images/logo-flutterando.png">
  </a>
  <p align="center">
    Built and maintained by <a href="https://www.flutterando.com.br">Flutterando</a>.
  </p>
</p>




<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- [Choose an Open Source License](https://choosealicense.com)
[GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
[Malven's Flexbox Cheatsheet](https://flexbox.malven.co/)
[Malven's Grid Cheatsheet](https://grid.malven.co/)
[Img Shields](https://shields.io)
[GitHub Pages](https://pages.github.com)
[Font Awesome](https://fontawesome.com)
[React Icons](https://react-icons.github.io/react-icons/search) 

[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com  -->
