# Infrastructure as Code for Beginners

<a href="https://www.packtpub.com/product/infrastructure-as-code-for-beginners/9781837631636?utm_source=github&utm_medium=repository&utm_campaign="><img src="https://content.packt.com/B19537/cover_image_small.jpg" alt="" height="256px" align="right"></a>

This is the code repository for [Infrastructure as Code for Beginners](https://www.packtpub.com/product/infrastructure-as-code-for-beginners/9781837631636?utm_source=github&utm_medium=repository&utm_campaign=), published by Packt.

**This book is for cloud engineers, software developers, or system administrators responsible for deploying resources to host applications. Ideal for both beginners and experienced professionals seeking to deepen their knowledge. Experience in manually deploying resources for applications in public clouds such as AWS or Microsoft Azure is a must. A basic understanding of programming or scripting languages, such as Python, Bash, PowerShell, etc. as well as familiarity with version control systems like Git, is a prerequisite.**

## What is this book about?
Infrastructure as Code for Beginners is an essential resource that helps you discover how IaC enables consistent and repeatable deployment and management of IaaS and PaaS services. It guides you through tool selection, implementation, and deployment on two cloud platforms and explores the pros and cons of different approaches.

This book covers the following exciting features:
* Determine the right time to implement Infrastructure as Code for your workload
* Select the appropriate approach for Infrastructure-as-Code deployment
* Get hands-on experience with Ansible and Terraform and understand their use cases
* Plan and deploy a workload to Azure and AWS clouds using Infrastructure as Code
* Leverage CI/CD in the cloud to deploy your infrastructure using your code
* Discover troubleshooting tips and tricks to avoid pitfalls during deployment

If you feel this book is for you, get your [copy](https://www.amazon.com/dp/1837631638) today!

<a href="https://www.packtpub.com/?utm_source=github&utm_medium=banner&utm_campaign=GitHubBanner"><img src="https://raw.githubusercontent.com/PacktPublishing/GitHub/master/GitHub.png" 
alt="https://www.packtpub.com/" border="5" /></a>

## Instructions and Navigations
All of the code is organized into folders. For example, Chapter01.

The code will look like the following:
```
name: pulumi-yaml
runtime: yaml
description: A minimal Azure Native Pulumi YAML program
outputs:
  primaryStorageKey: ${storageAccountKeys.keys[0].value}
```

**Following is what you need for this book:**
This book is for cloud engineers, software developers, or system administrators responsible for deploying resources to host applications. Ideal for both beginners and experienced professionals seeking to deepen their knowledge. Experience in manually deploying resources for applications in public clouds such as AWS or Microsoft Azure is a must. A basic understanding of programming or scripting languages, such as Python, Bash, PowerShell, etc. as well as familiarity with version control systems like Git, is a prerequisite.

With the following software and hardware list you can run all code files present in the book (Chapter 1-9).
### Software and Hardware List
| Chapter | Software required | OS required |
| -------- | ------------------------------------ | ----------------------------------- |
| 1-9 | Terraform  | Windows, Mac OS X, and Linux (Any) |
| 1-9 | Ansible | Windows, Mac OS X, and Linux (Any) |
| 1-9 | The Microsoft Azure CLI and portal | Windows, Mac OS X, and Linux (Any) |
| 1-9 | The Amazon Web Services CLI and portal  | Windows, Mac OS X, and Linux (Any) |
| 1-9 | Pulumi | Windows, Mac OS X, and Linux (Any) |
| 1-9 | Visual Studio Code | Windows, Mac OS X, and Linux (Any) |

We also provide a PDF file that has color images of the screenshots/diagrams used in this book. [Click here to download it](https://packt.link/uvP61).

### Errata
* Page 10: Figure 1.2 mentioned here is slightly incorrect. Here is the updated Figure:[1.2](https://github.com/PacktPublishing/Infrastructure-as-Code-for-Beginners/blob/main/img/1.2.png)

### Related products
* Infrastructure as Code with Azure Bicep [[Packt]](https://www.packtpub.com/product/infrastructure-as-code-with-azure-bicep/9781801813747?utm_source=github&utm_medium=repository&utm_campaign=9781801813747) [[Amazon]](https://www.amazon.com/dp/1801813744)

* Ansible for Real-Life Automation [[Packt]](https://www.packtpub.com/product/ansible-for-real-life-automation/9781803235417?utm_source=github&utm_medium=repository&utm_campaign=9781803235417) [[Amazon]](https://www.amazon.com/dp/1803235411)

## Get to Know the Author
**Russ McKendrick**
is an experienced DevOps practitioner and system administrator with a passion for automation and containers. He has been working in IT and related industries for the better part of 30 years. During his career, he has had responsibilities in many different sectors, including first-line, second-line, and senior support in client-facing and internal teams for small and large organizations.
He works almost exclusively with Linux, using open source systems and tools across dedicated hardware and virtual machines hosted in public and private clouds at Node4, where he holds the title of practice manager (SRE and DevOps). He also buys way too many records!
