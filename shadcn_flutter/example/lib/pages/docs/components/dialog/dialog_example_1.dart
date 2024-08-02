import 'package:shadcn_flutter/shadcn_flutter.dart';

class DialogExample1 extends StatelessWidget {
  const DialogExample1({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            final FormController controller = FormController();
            return Center(
              child: AlertDialog(
                title: const Text('Edit profile'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Make changes to your profile here. Click save when you\'re done'),
                    Gap(16),
                    Form(
                      controller: controller,
                      child: const FormTableLayout(rows: [
                        FormRow<String>(
                          key: FormKey(#name),
                          label: Text('Name'),
                          child: TextField(
                            initialValue: 'Thito Yalasatria Sunarya',
                          ),
                        ),
                        FormRow<String>(
                          key: FormKey(#username),
                          label: Text('Username'),
                          child: TextField(
                            initialValue: '@sunaryathito',
                          ),
                        ),
                      ]),
                    ).withPadding(vertical: 16),
                  ],
                ),
                actions: [
                  PrimaryButton(
                    child: const Text('Save changes'),
                    onPressed: () {
                      Navigator.of(context).pop(controller.values);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Text('Edit Profile'),
    );
  }
}
